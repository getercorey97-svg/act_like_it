-- Additive Multiplayer & Realtime Hardening Migration for ACT LIKE IT™
-- Ensures 2-8 player online lobbies, Realtime Postgres replication, storage uploads,
-- and safe guest/social onboarding work cleanly in production.

-- 1. Additive profile columns referenced by Flutter AuthService & LobbyRealtimeManager
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS display_name text,
  ADD COLUMN IF NOT EXISTS avatar_archetype text DEFAULT 'the_method_actor',
  ADD COLUMN IF NOT EXISTS bio_tagline text DEFAULT '',
  ADD COLUMN IF NOT EXISTS xp_points integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS tokens_balance integer DEFAULT 25,
  ADD COLUMN IF NOT EXISTS ai_tokens integer DEFAULT 25,
  ADD COLUMN IF NOT EXISTS is_18_plus boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS telemetry_opt_in boolean DEFAULT true;

-- 2. Additive lobby & lobby_players columns for 2-8 player synchronized turn order & scenes
ALTER TABLE public.lobbies
  ADD COLUMN IF NOT EXISTS selected_category text DEFAULT 'era_1970_1999',
  ADD COLUMN IF NOT EXISTS turn_selection_method text DEFAULT 'call_sheet_draw',
  ADD COLUMN IF NOT EXISTS current_player_index integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS used_scene_ids text[] DEFAULT ARRAY[]::text[],
  ADD COLUMN IF NOT EXISTS active_scene_payload jsonb,
  ADD COLUMN IF NOT EXISTS round_number integer DEFAULT 1;

ALTER TABLE public.lobby_players
  ADD COLUMN IF NOT EXISTS display_name text,
  ADD COLUMN IF NOT EXISTS avatar_archetype text DEFAULT 'the_method_actor',
  ADD COLUMN IF NOT EXISTS is_host boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_supporting_role boolean DEFAULT false;

-- 3. RLS Policies for multiplayer leaveLobby() & room state updates
DROP POLICY IF EXISTS "Lobby participants can update lobbies" ON public.lobbies;
CREATE POLICY "Lobby participants can update lobbies"
  ON public.lobbies
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Lobby players can update scores and readiness" ON public.lobby_players;
CREATE POLICY "Lobby players can update scores and readiness"
  ON public.lobby_players
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Lobby players can leave rooms" ON public.lobby_players;
CREATE POLICY "Lobby players can leave rooms"
  ON public.lobby_players
  FOR DELETE
  TO anon, authenticated
  USING (true);

-- 4. Supabase Storage bucket & policies for 30s MP4 replay loops (`performance-loops`)
INSERT INTO storage.buckets (id, name, public)
VALUES ('performance-loops', 'performance-loops', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public read performance-loops" ON storage.objects;
CREATE POLICY "Public read performance-loops"
  ON storage.objects
  FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'performance-loops');

DROP POLICY IF EXISTS "Players upload performance-loops" ON storage.objects;
CREATE POLICY "Players upload performance-loops"
  ON storage.objects
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (bucket_id = 'performance-loops');

DROP POLICY IF EXISTS "Players overwrite performance-loops" ON storage.objects;
CREATE POLICY "Players overwrite performance-loops"
  ON storage.objects
  FOR UPDATE
  TO anon, authenticated
  USING (bucket_id = 'performance-loops')
  WITH CHECK (bucket_id = 'performance-loops');

-- 5. Ensure Realtime Postgres Changes fire for public.lobbies & public.lobby_players
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = 'lobbies'
    ) THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.lobbies;
    END IF;

    IF NOT EXISTS (
      SELECT 1
      FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = 'lobby_players'
    ) THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.lobby_players;
    END IF;
  END IF;
END $$;
