-- ============================================================================
-- ACT LIKE IT — PART 2: SUPABASE POSTGRESQL SCHEMA & REALTIME MATCHMAKING
-- Target: Free-Tier Supabase PostgreSQL + Realtime Channels
-- Categories: Eras (1970-1999, 2000-2026), Awards (Best Actor, Best Actress,
--             Best Villain, Emmy Vault), Specialty (Cult Classics)
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. USER PROFILES
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null check (char_length(username) between 3 and 24),
  display_name text not null,
  avatar_url text,
  age_verified boolean not null default false,
  elo_rating integer not null default 1200,
  total_performances integer not null default 0,
  total_peer_votes integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Profiles are viewable by authenticated and anon players"
  on public.profiles for select
  using (true);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- 2. SCENE CATEGORY TABLES
-- ----------------------------------------------------------------------------

-- 2A. Eras (1970–1999)
create table if not exists public.scenes_era_1970_1999 (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  film_or_series text not null,
  release_year integer not null check (release_year between 1970 and 1999),
  character_name text not null,
  prompt_script text not null,
  director_cue text not null,
  emotional_target text not null,
  duration_seconds integer not null default 30,
  difficulty_tier integer not null default 2 check (difficulty_tier between 1 and 5),
  created_at timestamptz not null default now()
);

-- 2B. Eras (2000–2026)
create table if not exists public.scenes_era_2000_2026 (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  film_or_series text not null,
  release_year integer not null check (release_year between 2000 and 2026),
  character_name text not null,
  prompt_script text not null,
  director_cue text not null,
  emotional_target text not null,
  duration_seconds integer not null default 30,
  difficulty_tier integer not null default 2 check (difficulty_tier between 1 and 5),
  created_at timestamptz not null default now()
);

-- 2C. Awards Vault (Best Actor, Best Actress, Best Villain, Emmy Vault)
create table if not exists public.scenes_awards_vault (
  id uuid primary key default gen_random_uuid(),
  award_subcategory text not null check (
    award_subcategory in ('Best Actor', 'Best Actress', 'Best Villain', 'Emmy Vault')
  ),
  title text not null,
  film_or_series text not null,
  release_year integer not null,
  character_name text not null,
  prompt_script text not null,
  director_cue text not null,
  emotional_target text not null,
  duration_seconds integer not null default 35,
  difficulty_tier integer not null default 3 check (difficulty_tier between 1 and 5),
  created_at timestamptz not null default now()
);

-- 2D. Specialty (Cult Classics)
create table if not exists public.scenes_cult_classics (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  film_or_series text not null,
  release_year integer not null,
  character_name text not null,
  cult_subgenre text not null default 'Midnight Cinema',
  prompt_script text not null,
  director_cue text not null,
  emotional_target text not null,
  duration_seconds integer not null default 30,
  difficulty_tier integer not null default 2 check (difficulty_tier between 1 and 5),
  created_at timestamptz not null default now()
);

alter table public.scenes_era_1970_1999 enable row level security;
alter table public.scenes_era_2000_2026 enable row level security;
alter table public.scenes_awards_vault enable row level security;
alter table public.scenes_cult_classics enable row level security;

create policy "Public read access for 1970-1999 scenes"
  on public.scenes_era_1970_1999 for select using (true);

create policy "Public read access for 2000-2026 scenes"
  on public.scenes_era_2000_2026 for select using (true);

create policy "Public read access for awards vault scenes"
  on public.scenes_awards_vault for select using (true);

create policy "Public read access for cult classics scenes"
  on public.scenes_cult_classics for select using (true);

-- ----------------------------------------------------------------------------
-- 3. MULTIPLAYER LOBBIES & REALTIME STATE SYNCHRONIZATION (2-8 PLAYERS)
-- ----------------------------------------------------------------------------
create table if not exists public.lobbies (
  id uuid primary key default gen_random_uuid(),
  room_code char(6) unique not null check (room_code ~ '^[0-9]{6}$'),
  host_id uuid not null,
  selected_category text not null default 'era_1970_1999' check (
    selected_category in (
      'era_1970_1999',
      'era_2000_2026',
      'awards_best_actor',
      'awards_best_actress',
      'awards_best_villain',
      'awards_emmy_vault',
      'specialty_cult_classics',
      'late_night_after_hours'
    )
  ),
  status text not null default 'waiting' check (
    status in ('waiting', 'countdown', 'performing', 'judging', 'completed')
  ),
  min_players integer not null default 2 check (min_players >= 2),
  max_players integer not null default 8 check (max_players <= 8),
  active_actor_id uuid,
  active_scene_id uuid,
  active_scene_payload jsonb,
  round_number integer not null default 1,
  livekit_room_name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.lobby_players (
  id uuid primary key default gen_random_uuid(),
  lobby_id uuid not null references public.lobbies(id) on delete cascade,
  user_id uuid not null,
  display_name text not null,
  is_host boolean not null default false,
  is_ready boolean not null default false,
  ai_telemetrics_score numeric(5,2) not null default 0,
  peer_score numeric(5,2) not null default 0,
  social_score numeric(5,2) not null default 0,
  joined_at timestamptz not null default now(),
  unique (lobby_id, user_id)
);

-- Enforce 8-player maximum per LiveKit SFU room at database trigger level
create or replace function public.enforce_lobby_player_capacity()
returns trigger
language plpgsql
as $$
declare
  current_count integer;
  room_limit integer;
begin
  select count(*) into current_count
  from public.lobby_players
  where lobby_id = new.lobby_id;

  select max_players into room_limit
  from public.lobbies
  where id = new.lobby_id;

  if current_count >= coalesce(room_limit, 8) then
    raise exception 'Lobby has reached the maximum capacity of % remote players.', coalesce(room_limit, 8);
  end if;

  return new;
end;
$$;

drop trigger if exists trg_enforce_lobby_capacity on public.lobby_players;
create trigger trg_enforce_lobby_capacity
  before insert on public.lobby_players
  for each row execute function public.enforce_lobby_player_capacity();

alter table public.lobbies enable row level security;
alter table public.lobby_players enable row level security;

create policy "Anyone can read lobbies by room_code"
  on public.lobbies for select using (true);

create policy "Players can create lobbies"
  on public.lobbies for insert with check (true);

create policy "Host or players can update lobby state"
  on public.lobbies for update using (true);

create policy "Anyone in lobby can read lobby_players"
  on public.lobby_players for select using (true);

create policy "Players can join lobby_players"
  on public.lobby_players for insert with check (true);

create policy "Players can update their ready state and scores"
  on public.lobby_players for update using (true);

create policy "Players can leave lobby_players"
  on public.lobby_players for delete using (true);

-- Enable Supabase Realtime on lobbies and lobby_players
alter publication supabase_realtime add table public.lobbies;
alter publication supabase_realtime add table public.lobby_players;

-- ----------------------------------------------------------------------------
-- 4. INITIAL SEED SCENES ACROSS CATEGORIES
-- ----------------------------------------------------------------------------
insert into public.scenes_era_1970_1999
  (title, film_or_series, release_year, character_name, prompt_script, director_cue, emotional_target, duration_seconds, difficulty_tier)
values
  (
    'Tears in Rain',
    'Blade Runner',
    1982,
    'Roy Batty',
    'I have seen things you people wouldn''t believe. Attack ships on fire off the shoulder of Orion. All those moments will be lost in time, like tears in rain.',
    'Begin with quiet awe, maintain steady eye contact with the camera lens, and release a gentle breath on the final phrase.',
    'Melancholic Transcendence',
    30,
    4
  ),
  (
    'You Can''t Handle the Truth',
    'A Few Good Men',
    1992,
    'Col. Nathan R. Jessep',
    'You weep for Santiago, and you curse the Marines. You have that luxury. You have the luxury of not knowing what I know.',
    'Start with icy courtroom restraint before escalating vocal projection on the second sentence.',
    'Commanding Indignation',
    30,
    3
  );

insert into public.scenes_era_2000_2026
  (title, film_or_series, release_year, character_name, prompt_script, director_cue, emotional_target, duration_seconds, difficulty_tier)
values
  (
    'Not Quite My Tempo',
    'Whiplash',
    2014,
    'Terence Fletcher',
    'Were you rushing or were you dragging? If you deliberately sabotage my band, I will gut you like a pig.',
    'Whisper the opening question with razor-sharp stillness, then snap into sudden percussive intensity.',
    'Controlled Menace',
    25,
    4
  ),
  (
    'In Another Life',
    'Everything Everywhere All at Once',
    2022,
    'Waymond Wang',
    'In another life, I would have really liked just doing laundry and taxes with you.',
    'Soften your shoulders, let a bittersweet half-smile form, and deliver with vulnerable sincerity.',
    'Tender Vulnerability',
    25,
    3
  );

insert into public.scenes_awards_vault
  (award_subcategory, title, film_or_series, release_year, character_name, prompt_script, director_cue, emotional_target, duration_seconds, difficulty_tier)
values
  (
    'Best Actor',
    'I Drink Your Milkshake',
    'There Will Be Blood',
    2007,
    'Daniel Plainview',
    'If you have a milkshake, and I have a milkshake, and I have a straw... my straw reaches across the room. I drink your milkshake!',
    'Lean forward into the frame, build rhythmic cadence on the metaphor, and erupt on the final declaration.',
    'Ruthless Triumph',
    35,
    5
  ),
  (
    'Best Actress',
    'Look at What You Did',
    'Hereditary',
    2018,
    'Annie Graham',
    'All I do is worry and slave and defend you, and all I get back is that fucking face on your face!',
    'Hold trembling dinner-table composure for two beats before letting raw grief overtake the line.',
    'Shattered Grief & Fury',
    35,
    5
  ),
  (
    'Best Villain',
    'Call It, Friendo',
    'No Country for Old Men',
    2007,
    'Anton Chigurh',
    'What''s the most you ever lost on a coin toss? Don''t put it in your pocket. It''s your lucky quarter.',
    'Zero blinking, flat deadpan cadence, tilt chin slightly downward while staring directly into the lens.',
    'Unblinking Dread',
    30,
    4
  ),
  (
    'Emmy Vault',
    'I Am the One Who Knocks',
    'Breaking Bad',
    2011,
    'Walter White',
    'You clearly don''t know who you''re talking to, so let me clue you in. I am not in danger, Skyler. I am the danger.',
    'Drop vocal pitch half an octave and step closer to the microphone on the final five words.',
    'Ego & Cold Authority',
    30,
    4
  );

insert into public.scenes_cult_classics
  (title, film_or_series, release_year, character_name, cult_subgenre, prompt_script, director_cue, emotional_target, duration_seconds, difficulty_tier)
values
  (
    'Put That Coffee Down',
    'Glengarry Glen Ross',
    1992,
    'Blake',
    'Late-Night Stage Adaptation',
    'Coffee''s for closers only. You think I''m messing with you? I am not messing with you. Always be closing.',
    'Snap fingers once, pace the frame slightly, and deliver with rapid-fire boardroom swagger.',
    'Aggressive Salesmanship',
    30,
    3
  );
