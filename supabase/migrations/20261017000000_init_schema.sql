-- ============================================================================
-- ACT LIKE IT — INITIAL PRODUCTION SCHEMA & ROW LEVEL SECURITY MIGRATION
-- File: supabase/migrations/20261017000000_init_schema.sql
-- Target: Automated Supabase GitHub Integration ("Deploy to production")
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. PROFILES TABLE (Age-Gating via birth_year & User Identity)
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  birth_year integer not null check (
    birth_year >= 1900
    and birth_year <= extract(year from current_date)::integer
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2. SCENES TABLE (All Movie/TV Categories + Late-Night 18+ Flag)
-- ----------------------------------------------------------------------------
create table if not exists public.scenes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  actor_name text not null,
  character_name text not null,
  script_excerpt text not null,
  target_emotion text not null,
  category text not null check (
    category in (
      'Eras: 1970–1999',
      'Eras: 2000–2026',
      'Awards: Best Actor',
      'Awards: Best Actress',
      'Awards: Best Supporting Actor',
      'Awards: Best Villain',
      'Awards: Emmy Vault',
      'Specialty: Cult Classics',
      'Late-Night After-Hours'
    )
  ),
  is_late_night boolean not null default false,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 3. LOBBIES TABLE (6-Digit Matchmaking & Active Scene Synchronization)
-- ----------------------------------------------------------------------------
create table if not exists public.lobbies (
  id uuid primary key default gen_random_uuid(),
  room_code text not null unique check (room_code ~ '^[0-9]{6}$'),
  host_id uuid not null references public.profiles(id) on delete cascade,
  active_scene_id uuid references public.scenes(id) on delete set null,
  status text not null default 'waiting' check (
    status in ('waiting', 'performing', 'judging', 'completed')
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 4. LOBBY_PLAYERS JUNCTION TABLE (Multiplayer Roster & Scores)
-- ----------------------------------------------------------------------------
create table if not exists public.lobby_players (
  id uuid primary key default gen_random_uuid(),
  lobby_id uuid not null references public.lobbies(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  is_ready boolean not null default true,
  score numeric(5,2) not null default 0.00,
  joined_at timestamptz not null default now(),
  unique (lobby_id, user_id)
);

-- ----------------------------------------------------------------------------
-- 5. INDEXES FOR HIGH-SPEED MATCHMAKING & SCENE FILTERING
-- ----------------------------------------------------------------------------
create index if not exists idx_profiles_username
  on public.profiles(username);

create index if not exists idx_profiles_birth_year
  on public.profiles(birth_year);

create index if not exists idx_scenes_category
  on public.scenes(category);

create index if not exists idx_scenes_is_late_night
  on public.scenes(is_late_night);

create index if not exists idx_scenes_category_late_night
  on public.scenes(category, is_late_night);

create index if not exists idx_lobbies_room_code
  on public.lobbies(room_code);

create index if not exists idx_lobbies_host_id
  on public.lobbies(host_id);

create index if not exists idx_lobbies_active_scene_id
  on public.lobbies(active_scene_id);

create index if not exists idx_lobby_players_lobby_id
  on public.lobby_players(lobby_id);

create index if not exists idx_lobby_players_user_id
  on public.lobby_players(user_id);

-- ----------------------------------------------------------------------------
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ----------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.scenes enable row level security;
alter table public.lobbies enable row level security;
alter table public.lobby_players enable row level security;

-- PROFILES POLICIES
create policy "Profiles are viewable by authenticated users"
  on public.profiles
  for select
  to authenticated
  using (true);

create policy "Users can insert their own profile"
  on public.profiles
  for insert
  to authenticated
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- SCENES POLICIES (Strict 18+ Age-Gating on is_late_night = true)
create policy "Standard scenes (is_late_night = false) are viewable by everyone"
  on public.scenes
  for select
  using (is_late_night = false);

create policy "Late-Night scenes require verified 18+ birth_year in profiles"
  on public.scenes
  for select
  to authenticated
  using (
    is_late_night = true
    and exists (
      select 1
      from public.profiles p
      where p.id = auth.uid()
        and p.birth_year is not null
        and (extract(year from current_date)::integer - p.birth_year) >= 18
    )
  );

-- LOBBIES POLICIES
create policy "Lobbies are viewable by authenticated players"
  on public.lobbies
  for select
  to authenticated
  using (true);

create policy "Authenticated hosts can create lobbies"
  on public.lobbies
  for insert
  to authenticated
  with check (auth.uid() = host_id);

create policy "Lobby host can update lobby state and active_scene_id"
  on public.lobbies
  for update
  to authenticated
  using (auth.uid() = host_id)
  with check (auth.uid() = host_id);

create policy "Lobby host can delete lobby"
  on public.lobbies
  for delete
  to authenticated
  using (auth.uid() = host_id);

-- LOBBY_PLAYERS JUNCTION POLICIES
create policy "Lobby players are viewable by authenticated users"
  on public.lobby_players
  for select
  to authenticated
  using (true);

create policy "Authenticated users can join lobbies as themselves"
  on public.lobby_players
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Players can update their own lobby row or host can update"
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

create policy "Players can leave lobby or host can remove players"
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

-- ----------------------------------------------------------------------------
-- 7. SUPABASE REALTIME PUBLICATION FOR LOBBY STATE SYNCHRONIZATION
-- ----------------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lobbies'
    ) then
      alter publication supabase_realtime add table public.lobbies;
    end if;

    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'lobby_players'
    ) then
      alter publication supabase_realtime add table public.lobby_players;
    end if;
  end if;
end $$;
