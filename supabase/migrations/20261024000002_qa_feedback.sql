-- ============================================================================
-- ACT LIKE IT — S.O.A. Alpha QA Telemetry & Bug Reporting Schema
-- Migration: 20261024000002_qa_feedback.sql
-- Non-destructive additive migration for public.qa_feedback & qa-screenshots
-- ============================================================================

create extension if not exists "pgcrypto";

-- 1. Additive tester/admin flags on public.profiles (preserves existing schema)
alter table if exists public.profiles
  add column if not exists is_tester boolean not null default true,
  add column if not exists is_admin boolean not null default false;

-- 2. Create public.qa_feedback table
create table if not exists public.qa_feedback (
  id uuid primary key default gen_random_uuid(),
  tester_handle text not null,
  app_version text not null default '1.0.0+1',
  bug_type text not null check (bug_type in ('UI', 'Audio', 'AI Score', 'Crash')),
  screenshot_url text,
  device_info jsonb not null default '{}'::jsonb,
  local_state_dump jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_qa_feedback_created_at
  on public.qa_feedback (created_at desc);

create index if not exists idx_qa_feedback_bug_type
  on public.qa_feedback (bug_type);

-- 3. Enable Row Level Security (RLS) on public.qa_feedback
alter table public.qa_feedback enable row level security;

-- Policy A: Allow authenticated testers (and anonymous alpha sessions) to INSERT bug reports
drop policy if exists "qa_feedback_insert_testers" on public.qa_feedback;
create policy "qa_feedback_insert_testers"
  on public.qa_feedback
  for insert
  to authenticated, anon
  with check (true);

-- Policy B: Allow admins (and QA Web Portal readers) to SELECT bug reports
drop policy if exists "qa_feedback_select_admins" on public.qa_feedback;
create policy "qa_feedback_select_admins"
  on public.qa_feedback
  for select
  to authenticated, anon
  using (
    true
    or exists (
      select 1
      from public.profiles p
      where p.id = auth.uid()
        and (p.is_admin = true or p.is_tester = true)
    )
  );

-- 4. Provision the `qa-screenshots` Supabase Storage bucket
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'qa-screenshots',
  'qa-screenshots',
  true,
  10485760,
  array['image/png', 'image/jpeg', 'image/webp']
)
on conflict (id) do nothing;

-- Storage RLS Policies for `qa-screenshots`
drop policy if exists "qa_screenshots_insert_testers" on storage.objects;
create policy "qa_screenshots_insert_testers"
  on storage.objects
  for insert
  to authenticated, anon
  with check (bucket_id = 'qa-screenshots');

drop policy if exists "qa_screenshots_select_public" on storage.objects;
create policy "qa_screenshots_select_public"
  on storage.objects
  for select
  to authenticated, anon
  using (bucket_id = 'qa-screenshots');

-- 5. Add public.qa_feedback to Supabase Realtime publication for live Web Portal streaming
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'qa_feedback'
  ) then
    alter publication supabase_realtime add table public.qa_feedback;
  end if;
exception
  when others then null;
end $$;
