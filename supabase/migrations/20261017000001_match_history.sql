-- ============================================================================
-- ACT LIKE IT — MATCH HISTORY & WIN TRACKING MIGRATION
-- File: supabase/migrations/20261017000001_match_history.sql
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. MATCH_HISTORY TABLE
-- Stores completed round results, Tri-Modal score breakdowns, and win status.
-- ----------------------------------------------------------------------------
create table if not exists public.match_history (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.profiles(id) on delete cascade,
  scene_id uuid references public.scenes(id) on delete set null,
  ai_score numeric(5,2) not null default 0.00 check (ai_score >= 0 and ai_score <= 100),
  peer_score numeric(5,2) not null default 0.00 check (peer_score >= 0 and peer_score <= 100),
  social_score numeric(5,2) not null default 0.00 check (social_score >= 0 and social_score <= 100),
  final_score numeric(5,2) not null default 0.00 check (final_score >= 0 and final_score <= 100),
  is_win boolean not null default false,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2. INDEXES FOR CAREER TROPHY ROOM & LEADERBOARD QUERIES
-- ----------------------------------------------------------------------------
create index if not exists idx_match_history_player_id
  on public.match_history(player_id);

create index if not exists idx_match_history_scene_id
  on public.match_history(scene_id);

create index if not exists idx_match_history_created_at
  on public.match_history(created_at desc);

create index if not exists idx_match_history_player_wins
  on public.match_history(player_id, is_win);

-- ----------------------------------------------------------------------------
-- 3. STRICT ROW LEVEL SECURITY (RLS) POLICIES
-- Users may only read and insert their own match_history rows.
-- ----------------------------------------------------------------------------
alter table public.match_history enable row level security;

drop policy if exists "Users can read their own match history" on public.match_history;
create policy "Users can read their own match history"
  on public.match_history
  for select
  to authenticated
  using (auth.uid() = player_id);

drop policy if exists "Users can insert their own match history" on public.match_history;
create policy "Users can insert their own match history"
  on public.match_history
  for insert
  to authenticated
  with check (auth.uid() = player_id);
