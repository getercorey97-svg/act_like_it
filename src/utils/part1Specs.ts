export interface BatchStage {
  part: number;
  title: string;
  status: 'completed' | 'pending';
  targetFiles: string[];
  summary: string;
}

export interface GeneratedFileRecord {
  path: string;
  language: 'yaml' | 'dart' | 'sql';
  part: number;
  description: string;
  lineCount: number;
  content: string;
}

export const BATCH_STAGES: BatchStage[] = [
  {
    part: 1,
    title: 'Initialization & Dependencies',
    status: 'completed',
    targetFiles: ['pubspec.yaml', 'analysis_options.yaml', 'lib/main.dart'],
    summary:
      'Root Flutter directory structure, Supabase + LiveKit + Gemini dependencies in pubspec.yaml, and foundational lib/main.dart shell.',
  },
  {
    part: 2,
    title: 'Database & Matchmaking',
    status: 'completed',
    targetFiles: ['supabase/schema.sql', 'lib/lobby.dart'],
    summary:
      'Supabase PostgreSQL schema for Eras, Awards, Cult Classics, and User Profiles, plus 6-digit lobby matchmaking via Supabase Realtime.',
  },
  {
    part: 3,
    title: 'Real-Time Media Routing',
    status: 'pending',
    targetFiles: ['lib/webrtc_manager.dart'],
    summary:
      'LiveKit WebRTC camera capture and SFU broadcast architecture supporting 2 to 8 remote players without bandwidth throttling.',
  },
  {
    part: 4,
    title: 'AI Telemetrics & UI Looping',
    status: 'pending',
    targetFiles: ['lib/judging_engine.dart'],
    summary:
      'Tri-Modal Judging: Gemini multimodal frame evaluation, Supabase Storage looped video replay for Peer Judging, and Social share metric scoring.',
  },
  {
    part: 5,
    title: 'Late-Night After-Hours Module',
    status: 'pending',
    targetFiles: ['supabase/late_night_schema.sql', 'lib/late_night_vault.dart'],
    summary:
      'Secure age-gating, RLS policies, mechanics, and prompt structures for the hidden Late-Night After-Hours table.',
  },
];

export const WORKSPACE_FILES: GeneratedFileRecord[] = [
  {
    path: 'supabase/schema.sql',
    language: 'sql',
    part: 2,
    description:
      'PostgreSQL DDL & RLS policies for profiles, scenes_era_1970_1999, scenes_era_2000_2026, scenes_awards_vault, scenes_cult_classics, lobbies, and lobby_players with 8-player trigger.',
    lineCount: 289,
    content: `-- ACT LIKE IT — PART 2: SUPABASE POSTGRESQL SCHEMA & REALTIME MATCHMAKING
create extension if not exists "pgcrypto";

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
  difficulty_tier integer not null default 2 check (difficulty_tier between 1 and 5)
);

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
  difficulty_tier integer not null default 2 check (difficulty_tier between 1 and 5)
);

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
  difficulty_tier integer not null default 3 check (difficulty_tier between 1 and 5)
);

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
  difficulty_tier integer not null default 2 check (difficulty_tier between 1 and 5)
);

create table if not exists public.lobbies (
  id uuid primary key default gen_random_uuid(),
  room_code char(6) unique not null check (room_code ~ '^[0-9]{6}$'),
  host_id uuid not null,
  selected_category text not null default 'era_1970_1999',
  status text not null default 'waiting',
  min_players integer not null default 2 check (min_players >= 2),
  max_players integer not null default 8 check (max_players <= 8),
  active_actor_id uuid,
  active_scene_id uuid,
  active_scene_payload jsonb,
  round_number integer not null default 1,
  livekit_room_name text not null
);

alter publication supabase_realtime add table public.lobbies;
alter publication supabase_realtime add table public.lobby_players;`,
  },
  {
    path: 'lib/lobby.dart',
    language: 'dart',
    part: 2,
    description:
      'Matchmaking & Supabase Realtime controller (LobbyRealtimeManager) + LobbyMatchmakingScreen for 6-digit room codes and 2–8 remote players.',
    lineCount: 622,
    content: `import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

enum SceneCategory {
  era1970To1999(
    key: 'era_1970_1999',
    label: 'Eras: 1970–1999',
    table: 'scenes_era_1970_1999',
    awardFilter: null,
  ),
  era2000To2026(
    key: 'era_2000_2026',
    label: 'Eras: 2000–2026',
    table: 'scenes_era_2000_2026',
    awardFilter: null,
  ),
  awardsBestActor(
    key: 'awards_best_actor',
    label: 'Awards: Best Actor',
    table: 'scenes_awards_vault',
    awardFilter: 'Best Actor',
  ),
  awardsBestActress(
    key: 'awards_best_actress',
    label: 'Awards: Best Actress',
    table: 'scenes_awards_vault',
    awardFilter: 'Best Actress',
  ),
  awardsBestVillain(
    key: 'awards_best_villain',
    label: 'Awards: Best Villain',
    table: 'scenes_awards_vault',
    awardFilter: 'Best Villain',
  ),
  awardsEmmyVault(
    key: 'awards_emmy_vault',
    label: 'Awards: Emmy Vault',
    table: 'scenes_awards_vault',
    awardFilter: 'Emmy Vault',
  ),
  specialtyCultClassics(
    key: 'specialty_cult_classics',
    label: 'Specialty: Cult Classics',
    table: 'scenes_cult_classics',
    awardFilter: null,
  );

  final String key;
  final String label;
  final String table;
  final String? awardFilter;

  const SceneCategory({
    required this.key,
    required this.label,
    required this.table,
    required this.awardFilter,
  });
}

class LobbyRealtimeManager extends ChangeNotifier {
  static String generateSixDigitCode() {
    final random = Random.secure();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }
  // Subscribes to 'lobby:\$roomCode' Postgres Changes & Broadcast events
}`,
  },
  {
    path: 'pubspec.yaml',
    language: 'yaml',
    part: 1,
    description:
      'Flutter manifest configuring supabase_flutter, livekit_client, flutter_webrtc, google_generative_ai, and video_player.',
    lineCount: 44,
    content: `name: act_like_it
description: >-
  Act Like It — A full-stack real-time multiplayer acting and performance game
  powered by Supabase (PostgreSQL, Realtime Channels, Edge Storage), LiveKit
  WebRTC SFU (2-8 remote players), and Google Gemini Multimodal AI Telemetrics.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.0
  livekit_client: ^2.3.0
  flutter_webrtc: ^0.12.0
  google_generative_ai: ^0.4.6
  video_player: ^2.9.2
  camera: ^0.11.0+2
  permission_handler: ^11.3.1
  path_provider: ^2.1.5
  provider: ^6.1.2
  shared_preferences: ^2.3.2
  share_plus: ^10.1.2
  http: ^1.2.2
  uuid: ^4.5.1
  intl: ^0.19.0
  cupertino_icons: ^1.0.8`,
  },
  {
    path: 'lib/main.dart',
    language: 'dart',
    part: 1,
    description:
      'Foundational entry point initializing Supabase (10 EPS Realtime) and routing SoundstageShellScreen to LobbyMatchmakingScreen.',
    lineCount: 294,
    content: `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lobby.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 10,
    ),
  );
  runApp(const ActLikeItApp());
}`,
  },
];

export const PART_1_FILES = WORKSPACE_FILES;

export function validateFlutterPubspec(yamlContent: string): {
  valid: boolean;
  hasSupabase: boolean;
  hasLiveKit: boolean;
  hasGemini: boolean;
} {
  const hasSupabase = yamlContent.includes('supabase_flutter:');
  const hasLiveKit = yamlContent.includes('livekit_client:');
  const hasGemini = yamlContent.includes('google_generative_ai:');
  return {
    valid: hasSupabase && hasLiveKit && hasGemini,
    hasSupabase,
    hasLiveKit,
    hasGemini,
  };
}

export function validatePart2Schema(sqlContent: string): {
  valid: boolean;
  hasProfiles: boolean;
  hasErasTables: boolean;
  hasAwardsTable: boolean;
  hasCultClassicsTable: boolean;
  hasLobbiesRealtime: boolean;
} {
  const hasProfiles = sqlContent.includes('public.profiles');
  const hasErasTables =
    sqlContent.includes('public.scenes_era_1970_1999') &&
    sqlContent.includes('public.scenes_era_2000_2026');
  const hasAwardsTable =
    sqlContent.includes('public.scenes_awards_vault') &&
    sqlContent.includes("'Best Actor'") &&
    sqlContent.includes("'Best Actress'") &&
    sqlContent.includes("'Best Villain'") &&
    sqlContent.includes("'Emmy Vault'");
  const hasCultClassicsTable = sqlContent.includes('public.scenes_cult_classics');
  const hasLobbiesRealtime =
    sqlContent.includes('public.lobbies') &&
    sqlContent.includes('supabase_realtime');

  return {
    valid:
      hasProfiles &&
      hasErasTables &&
      hasAwardsTable &&
      hasCultClassicsTable &&
      hasLobbiesRealtime,
    hasProfiles,
    hasErasTables,
    hasAwardsTable,
    hasCultClassicsTable,
    hasLobbiesRealtime,
  };
}

export function isSixDigitLobbyCode(code: string): boolean {
  return /^[0-9]{6}$/.test(code.trim());
}

export function getBatchCompletionRatio(stages: BatchStage[]): {
  completedCount: number;
  totalCount: number;
  percentage: number;
} {
  const totalCount = stages.length;
  const completedCount = stages.filter((s) => s.status === 'completed').length;
  const percentage = totalCount === 0 ? 0 : Math.round((completedCount / totalCount) * 100);
  return { completedCount, totalCount, percentage };
}
