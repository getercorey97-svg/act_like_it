-- ============================================================================
-- ACT LIKE IT — PART 5: LATE-NIGHT AFTER-HOURS HIDDEN / AGE-GATED VAULT
-- Target: Supabase PostgreSQL with Strict 18+ Row-Level Security (RLS)
-- ============================================================================

create table if not exists public.scenes_late_night_after_hours (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  film_or_series text not null,
  release_year integer not null,
  character_name text not null,
  spice_tier integer not null default 2 check (spice_tier between 1 and 3),
  content_advisory text not null,
  prompt_script text not null,
  director_cue text not null,
  emotional_target text not null,
  improvisation_twist text not null,
  duration_seconds integer not null default 35,
  difficulty_tier integer not null default 4 check (difficulty_tier between 1 and 5),
  created_at timestamptz not null default now()
);

alter table public.scenes_late_night_after_hours enable row level security;

-- Strict RLS Policy: Only authenticated users whose profile has age_verified = true
-- can SELECT rows from the hidden Late-Night After-Hours table.
drop policy if exists "Age-verified 18+ players only" on public.scenes_late_night_after_hours;
create policy "Age-verified 18+ players only"
  on public.scenes_late_night_after_hours
  for select
  using (
    exists (
      select 1
      from public.profiles
      where profiles.id = auth.uid()
        and profiles.age_verified = true
    )
  );

-- Secure RPC Function: Validates 18+ birth year, marks profile age_verified = true,
-- and returns whether the Late-Night vault is unlocked for the caller.
create or replace function public.verify_player_age_and_unlock_late_night(
  p_birth_year integer,
  p_session_pin text
)
returns boolean
language plpgsql
security definer
as $$
declare
  v_current_year integer := extract(year from current_date)::integer;
  v_age integer := v_current_year - p_birth_year;
begin
  if v_age < 18 or p_birth_year < 1900 then
    raise exception 'Age verification failed: Players must be 18 or older to unlock Late-Night After-Hours.';
  end if;

  if char_length(trim(p_session_pin)) <> 4 then
    raise exception 'A 4-digit session PIN is required to lock/unlock the After-Hours vault.';
  end if;

  if auth.uid() is not null then
    update public.profiles
    set age_verified = true,
        updated_at = now()
    where id = auth.uid();
  end if;

  return true;
end;
$$;

-- Seed Late-Night After-Hours Prompts with Mid-Take Improvisation Twists
insert into public.scenes_late_night_after_hours
  (title, film_or_series, release_year, character_name, spice_tier, content_advisory, prompt_script, director_cue, emotional_target, improvisation_twist, duration_seconds, difficulty_tier)
values
  (
    'This Is How I Win',
    'Uncut Gems',
    2019,
    'Howard Ratner',
    1,
    '18+ Language & High-Anxiety Gambling Spiral',
    'You''re having a good time, right? Look at this parlay. I disagree. I disagree, Gary! This is how I win!',
    'Speak at 1.4x speed with manic grinning confidence while pretending to lock the security door.',
    'Manic Euphoria & Desperation',
    'TWIST AT 15s: The buzzer jams—deliver the final line while whispering in sheer claustrophobic panic.',
    35,
    4
  ),
  (
    'The Adrenaline Shot Count',
    'Pulp Fiction',
    1994,
    'Vincent Vega & Lance',
    2,
    '18+ Mature Themes & Dark Panic Comedy',
    'I''m gonna count to three, and when I count three, you plunge that needle straight down. One... two...',
    'Hold an imaginary marker poised inches above the camera lens, eyes wide with sweat-drenched hesitation.',
    'Hysterical Hesitation',
    'TWIST AT 15s: Switch roles mid-sentence and react as if you just woke up from a dead faint.',
    35,
    4
  ),
  (
    'I''m Not Leaving',
    'The Wolf of Wall Street',
    2013,
    'Jordan Belfort',
    2,
    '18+ Explicit Trading Floor Tirade',
    'I''m not leaving. I''m not leaving! The show goes on! This is my home. They''re gonna need a wrecking ball to take me out of here!',
    'Begin with deceptively quiet, defeated posture, then slam your palm into the frame and roar into the mic.',
    'Unhinged Defiance',
    'TWIST AT 15s: Deliver the climax as if your microphone just cut out and you have to mime half the words.',
    40,
    5
  ),
  (
    'The Masked Confession',
    'Eyes Wide Shut',
    1999,
    'Bill & Alice Harford',
    3,
    '18+ Psychological Intimacy & After-Hours Tension',
    'If you men only knew... There is something very important that we need to do as soon as possible.',
    'Slow your cadence to half-speed, hold an unblinking gaze three inches from the front camera, and barely part your lips.',
    'Hypnotic Vulnerability',
    'TWIST AT 15s: Break into a sudden, unsettling laugh before snapping back to deadpan seriousness.',
    40,
    5
  );
