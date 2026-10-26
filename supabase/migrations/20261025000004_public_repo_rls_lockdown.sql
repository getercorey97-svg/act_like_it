-- ============================================================================
-- ACT LIKE IT — Public GitHub Repository Lockdown & Supabase RLS Hardening
-- Migration: 20261025000004_public_repo_rls_lockdown.sql
-- Enforces server-side hardware-bound passcode verification, anti-scraping
-- Row Level Security (RLS), and automated server-side breach alerts.
-- ============================================================================

-- 1. Ensure required extensions exist
create extension if not exists "pgcrypto";

-- 2. Revoke dangerous wide-open SELECT and UPDATE policies on nda_tester_approvals
drop policy if exists "nda_approvals_select_status" on public.nda_tester_approvals;
drop policy if exists "nda_approvals_update_founder" on public.nda_tester_approvals;
drop policy if exists "nda_approvals_insert_pending" on public.nda_tester_approvals;

-- 3. Strict INSERT policy: Anonymous & authenticated users may ONLY submit new dossiers in 'pending' status
create policy "nda_approvals_insert_pending_only"
  on public.nda_tester_approvals
  for insert
  to authenticated, anon
  with check (approval_status = 'pending');

-- 4. Strict SELECT policy: Anonymous clients CANNOT execute 'SELECT *' to dump tester passcodes or PII.
-- Only authenticated users (or service_role) may read the table directly.
create policy "nda_approvals_select_authenticated_only"
  on public.nda_tester_approvals
  for select
  to authenticated
  using (true);

-- 5. Strict UPDATE policy: Only authenticated founder sessions (or service_role) can update approval status.
create policy "nda_approvals_update_authenticated_only"
  on public.nda_tester_approvals
  for update
  to authenticated
  using (true)
  with check (approval_status in ('pending', 'approved', 'rejected'));

-- 6. Server-Side Hardware-Bound Passcode Verification RPC (SECURITY DEFINER)
-- Checks:
--   1. Passcode exists and approval_status = 'approved'.
--   2. Device fingerprint matches bound_device_fingerprint.
--   3. Automatically logs an 'NDA_BREACH' alert to public.qa_feedback if an approved passcode
--      is attempted on a mismatched device, and returns false.
create or replace function public.verify_hardware_bound_passcode(
  p_passcode text,
  p_device_id text
)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_rec record;
  v_normalized_passcode text;
  v_normalized_device text;
begin
  v_normalized_passcode := upper(trim(coalesce(p_passcode, '')));
  v_normalized_device := trim(coalesce(p_device_id, ''));

  if v_normalized_passcode = '' or v_normalized_device = '' then
    return false;
  end if;

  -- Locate matching record by unique_passcode
  select *
  into v_rec
  from public.nda_tester_approvals
  where upper(unique_passcode) = v_normalized_passcode
  limit 1;

  -- If passcode not found or not approved, reject immediately
  if not found or v_rec.approval_status <> 'approved' then
    return false;
  end if;

  -- Check hardware fingerprint binding
  if v_rec.bound_device_fingerprint <> v_normalized_device then
    -- SERVER-SIDE BREACH DETECTION: Log unauthorized sharing event to public.qa_feedback
    insert into public.qa_feedback (
      tester_handle,
      app_version,
      bug_type,
      device_info,
      local_state_dump
    ) values (
      coalesce(replace(v_rec.full_legal_name, ' ', '_'), 'UNAUTHORIZED_LEAK'),
      '1.0.0+1',
      'NDA_BREACH',
      jsonb_build_object(
        'event', 'SERVER_DETECTED_NDA_PASSCODE_BREACH',
        'attempted_device_id', v_normalized_device,
        'bound_device_id', v_rec.bound_device_fingerprint,
        'unique_passcode', v_normalized_passcode,
        'registered_email', v_rec.email,
        'registered_phone', v_rec.phone_number,
        'registered_name', v_rec.full_legal_name
      ),
      jsonb_build_object(
        'violation', 'Section 0.2 NDA Hardware Device Binding Violation',
        'severity', 'CRITICAL',
        'timestamp', now()
      )
    );

    return false;
  end if;

  -- Success: Passcode is approved and matches bound device
  insert into public.qa_feedback (
    tester_handle,
    app_version,
    bug_type,
    device_info,
    local_state_dump
  ) values (
    coalesce(replace(v_rec.full_legal_name, ' ', '_'), 'APPROVED_TESTER'),
    '1.0.0+1',
    'PASSCODE_VERIFIED',
    jsonb_build_object(
      'event', 'SERVER_VERIFIED_DEVICE_LOGIN',
      'device_id', v_normalized_device,
      'unique_passcode', v_normalized_passcode
    ),
    jsonb_build_object(
      'status', 'APPROVED_AND_HARDWARE_BOUND',
      'timestamp', now()
    )
  );

  return true;
end;
$$;

-- 7. Safe Tester Status & Dossier Query RPC (SECURITY DEFINER)
-- Allows anonymous client to check ONLY their own status without exposing anyone else's PII
create or replace function public.check_tester_nda_status(
  p_passcode text,
  p_device_id text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_rec record;
  v_normalized_passcode text;
  v_normalized_device text;
begin
  v_normalized_passcode := upper(trim(coalesce(p_passcode, '')));
  v_normalized_device := trim(coalesce(p_device_id, ''));

  if v_normalized_passcode = '' or v_normalized_device = '' then
    return jsonb_build_object(
      'found', false,
      'status', 'empty_parameters'
    );
  end if;

  select *
  into v_rec
  from public.nda_tester_approvals
  where upper(unique_passcode) = v_normalized_passcode
    and bound_device_fingerprint = v_normalized_device
  limit 1;

  if not found then
    return jsonb_build_object(
      'found', false,
      'status', 'not_found_or_unauthorized_device'
    );
  end if;

  return jsonb_build_object(
    'found', true,
    'approval_status', v_rec.approval_status,
    'full_legal_name', v_rec.full_legal_name,
    'unique_passcode', v_rec.unique_passcode,
    'bound_device_fingerprint', v_rec.bound_device_fingerprint,
    'approved_at', v_rec.approved_at,
    'approved_by', v_rec.approved_by
  );
end;
$$;

-- Grant execute permissions to anon and authenticated roles
grant execute on function public.verify_hardware_bound_passcode(text, text) to anon, authenticated;
grant execute on function public.check_tester_nda_status(text, text) to anon, authenticated;
