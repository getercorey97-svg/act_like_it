-- ============================================================================
-- ACT LIKE IT — PRODUCTION SCHEMA & ROW LEVEL SECURITY MIGRATION
-- File: supabase/migrations/20261017000000_init_schema.sql
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. PROFILES TABLE (id references auth.users, username, birth_year)
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  birth_year integer not null check (birth_year >= 1900 and birth_year <= 2100),
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2. SCENES TABLE (90 General Scenes + 10 Late-Night Mirror Rows)
-- ----------------------------------------------------------------------------
create table if not exists public.scenes (
  id uuid primary key default gen_random_uuid(),
  scene_code text unique,
  title text not null,
  actor_name text not null,
  character_name text not null,
  release_year integer not null default 2000,
  script_excerpt text not null,
  duet_lead_a text not null default '',
  duet_lead_b text not null default '',
  director_note text not null default '',
  target_emotion text not null,
  improv_twist text not null default '',
  category text not null,
  is_18_plus boolean not null default false,
  is_late_night boolean not null default false,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2B. SCENES_LATE_NIGHT_AFTER_HOURS TABLE (10 Age-Gated 18+ Parody Scenes)
-- ----------------------------------------------------------------------------
create table if not exists public.scenes_late_night_after_hours (
  id uuid primary key default gen_random_uuid(),
  scene_code text unique not null,
  title text not null,
  actor_name text not null,
  character_name text not null,
  release_year integer not null default 2004,
  script_excerpt text not null,
  duet_lead_a text not null default '',
  duet_lead_b text not null default '',
  director_note text not null default '',
  target_emotion text not null,
  improv_twist text not null default '',
  spice_tier integer not null default 3,
  content_advisory text not null default '18+ High-Tension Romantic & Dramatic Dialogue',
  is_18_plus boolean not null default true,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 3. LOBBIES TABLE (room_code, host_id, active_scene_id, status)
-- ----------------------------------------------------------------------------
create table if not exists public.lobbies (
  id uuid primary key default gen_random_uuid(),
  room_code text unique not null,
  host_id uuid not null references public.profiles(id) on delete cascade,
  active_scene_id uuid references public.scenes(id) on delete set null,
  status text not null default 'waiting',
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 4. LOBBY_PLAYERS JUNCTION TABLE (Multiplayer Roster)
-- ----------------------------------------------------------------------------
create table if not exists public.lobby_players (
  id uuid primary key default gen_random_uuid(),
  lobby_id uuid not null references public.lobbies(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  is_ready boolean not null default true,
  joined_at timestamptz not null default now(),
  unique (lobby_id, user_id)
);

-- ----------------------------------------------------------------------------
-- 5. INDEXES
-- ----------------------------------------------------------------------------
create index if not exists idx_profiles_username on public.profiles(username);
create index if not exists idx_profiles_birth_year on public.profiles(birth_year);
create index if not exists idx_scenes_category on public.scenes(category);
create index if not exists idx_scenes_is_late_night on public.scenes(is_late_night);
create index if not exists idx_scenes_late_night_spice_tier on public.scenes_late_night_after_hours(spice_tier);
create index if not exists idx_lobbies_room_code on public.lobbies(room_code);
create index if not exists idx_lobbies_host_id on public.lobbies(host_id);
create index if not exists idx_lobbies_active_scene_id on public.lobbies(active_scene_id);
create index if not exists idx_lobby_players_lobby_id on public.lobby_players(lobby_id);
create index if not exists idx_lobby_players_user_id on public.lobby_players(user_id);

-- ----------------------------------------------------------------------------
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ----------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.scenes enable row level security;
alter table public.scenes_late_night_after_hours enable row level security;
alter table public.lobbies enable row level security;
alter table public.lobby_players enable row level security;

-- PROFILES RLS
drop policy if exists "Profiles are viewable by authenticated users" on public.profiles;
create policy "Profiles are viewable by authenticated users"
  on public.profiles
  for select
  to authenticated
  using (true);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
  on public.profiles
  for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- SCENES RLS (Strict 18+ Age-Gating for is_late_night = true via birth_year)
drop policy if exists "Standard scenes are viewable by everyone" on public.scenes;
create policy "Standard scenes are viewable by everyone"
  on public.scenes
  for select
  using (is_late_night = false and is_18_plus = false);

drop policy if exists "Late-Night scenes require 18+ birth_year" on public.scenes;
create policy "Late-Night scenes require 18+ birth_year"
  on public.scenes
  for select
  to authenticated
  using (
    (is_late_night = true or is_18_plus = true)
    and exists (
      select 1
      from public.profiles p
      where p.id = auth.uid()
        and p.birth_year is not null
        and (extract(year from current_date)::integer - p.birth_year) >= 18
    )
  );

drop policy if exists "After-Hours table requires 18+ birth_year" on public.scenes_late_night_after_hours;
create policy "After-Hours table requires 18+ birth_year"
  on public.scenes_late_night_after_hours
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.profiles p
      where p.id = auth.uid()
        and p.birth_year is not null
        and (extract(year from current_date)::integer - p.birth_year) >= 18
    )
  );

-- LOBBIES RLS
drop policy if exists "Lobbies are viewable by authenticated users" on public.lobbies;
create policy "Lobbies are viewable by authenticated users"
  on public.lobbies
  for select
  to authenticated
  using (true);

drop policy if exists "Authenticated hosts can create lobbies" on public.lobbies;
create policy "Authenticated hosts can create lobbies"
  on public.lobbies
  for insert
  to authenticated
  with check (auth.uid() = host_id);

drop policy if exists "Hosts can update their lobbies" on public.lobbies;
create policy "Hosts can update their lobbies"
  on public.lobbies
  for update
  to authenticated
  using (auth.uid() = host_id)
  with check (auth.uid() = host_id);

drop policy if exists "Hosts can delete their lobbies" on public.lobbies;
create policy "Hosts can delete their lobbies"
  on public.lobbies
  for delete
  to authenticated
  using (auth.uid() = host_id);

-- LOBBY_PLAYERS RLS
drop policy if exists "Lobby players are viewable by authenticated users" on public.lobby_players;
create policy "Lobby players are viewable by authenticated users"
  on public.lobby_players
  for select
  to authenticated
  using (true);

drop policy if exists "Users can join lobbies as themselves" on public.lobby_players;
create policy "Users can join lobbies as themselves"
  on public.lobby_players
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Players or hosts can update lobby player rows" on public.lobby_players;
create policy "Players or hosts can update lobby player rows"
  on public.lobby_players
  for update
  to authenticated
  using (
    auth.uid() = user_id
    or exists (
      select 1
      from public.lobbies l
      where l.id = lobby_players.lobby_id
        and l.host_id = auth.uid()
    )
  );

drop policy if exists "Players can leave or hosts can remove players" on public.lobby_players;
create policy "Players can leave or hosts can remove players"
  on public.lobby_players
  for delete
  to authenticated
  using (
    auth.uid() = user_id
    or exists (
      select 1
      from public.lobbies l
      where l.id = lobby_players.lobby_id
        and l.host_id = auth.uid()
    )
  );
