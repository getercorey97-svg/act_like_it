-- ============================================================================
-- ACT LIKE IT — Manual Founder NDA Approval Queue & Device-Bound Passcode Table
-- Migration: 20261025000003_nda_tester_approvals.sql
-- Ensures public GitHub visitors who sign the NDA remain in 'pending' status
-- with their ALI-XX-XXXX passcode hidden until approved by the Founder.
-- ============================================================================

create extension if not exists "pgcrypto";

-- 1. Create public.nda_tester_approvals table for Supabase Table Editor + In-App Founder Admin Queue
create table if not exists public.nda_tester_approvals (
  id uuid primary key default gen_random_uuid(),
  full_legal_name text not null,
  email text not null,
  phone_number text not null,
  digital_signature text not null,
  unique_passcode text not null unique,
  bound_device_fingerprint text not null,
  device_model text not null default '',
  os_version text not null default '',
  network_connection_used text not null default 'Both Tested',
  agreed_17_usc_102_copyright boolean not null default true,
  agreed_strict_nda_no_recording_or_sharing boolean not null default true,
  interested_in_partnership boolean not null default false,
  selected_partnership_tracks jsonb not null default '[]'::jsonb,
  partnership_background_summary text not null default '',
  approval_status text not null default 'pending'
    check (approval_status in ('pending', 'approved', 'rejected')),
  approved_by text,
  approved_at timestamptz,
  founder_notes text not null default '',
  official_portal_url text not null default 'https://act-like-it.vercel.app',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_nda_tester_approvals_status
  on public.nda_tester_approvals (approval_status, created_at desc);

create index if not exists idx_nda_tester_approvals_passcode
  on public.nda_tester_approvals (unique_passcode);

create index if not exists idx_nda_tester_approvals_device_fp
  on public.nda_tester_approvals (bound_device_fingerprint);

-- 2. Enable Row Level Security (RLS) on public.nda_tester_approvals
alter table public.nda_tester_approvals enable row level security;

-- Policy A: Allow testers to submit their signed NDA dossier into the 'pending' queue
drop policy if exists "nda_approvals_insert_pending" on public.nda_tester_approvals;
create policy "nda_approvals_insert_pending"
  on public.nda_tester_approvals
  for insert
  to authenticated, anon
  with check (approval_status in ('pending', 'approved'));

-- Policy B: Allow status checks and Founder Admin Queue inspection
drop policy if exists "nda_approvals_select_status" on public.nda_tester_approvals;
create policy "nda_approvals_select_status"
  on public.nda_tester_approvals
  for select
  to authenticated, anon
  using (true);

-- Policy C: Allow Founder Admin Queue & Supabase Dashboard to approve or reject testers
drop policy if exists "nda_approvals_update_founder" on public.nda_tester_approvals;
create policy "nda_approvals_update_founder"
  on public.nda_tester_approvals
  for update
  to authenticated, anon
  using (true)
  with check (approval_status in ('pending', 'approved', 'rejected'));

-- 3. Expand qa_feedback bug_type constraint so NDA telemetry events are also accepted
alter table if exists public.qa_feedback
  drop constraint if exists qa_feedback_bug_type_check;

alter table if exists public.qa_feedback
  add constraint qa_feedback_bug_type_check
  check (
    bug_type in (
      'UI',
      'Audio',
      'AI Score',
      'Crash',
      'NDA_SIGNED',
      'NDA_APPROVED',
      'NDA_REJECTED',
      'NDA_BREACH',
      'PASSCODE_VERIFIED'
    )
  );

-- 4. Add public.nda_tester_approvals to Supabase Realtime publication
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'nda_tester_approvals'
  ) then
    alter publication supabase_realtime add table public.nda_tester_approvals;
  end if;
exception
  when others then null;
end $$;
