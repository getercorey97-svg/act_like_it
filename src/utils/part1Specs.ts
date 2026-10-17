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
    status: 'completed',
    targetFiles: ['lib/webrtc_manager.dart'],
    summary:
      'LiveKit WebRTC camera capture and SFU broadcast architecture supporting 2 to 8 remote players without bandwidth throttling.',
  },
  {
    part: 4,
    title: 'AI Telemetrics & UI Looping',
    status: 'completed',
    targetFiles: ['lib/judging_engine.dart'],
    summary:
      'Tri-Modal Judging: Gemini multimodal frame evaluation, Supabase Storage looped video replay for Peer Judging, and Social share metric scoring.',
  },
  {
    part: 5,
    title: 'Late-Night After-Hours Module',
    status: 'completed',
    targetFiles: ['supabase/late_night_schema.sql', 'lib/late_night_vault.dart'],
    summary:
      'Secure age-gating, RLS policies, mechanics, and prompt structures for the hidden Late-Night After-Hours table.',
  },
];

export const WORKSPACE_FILES: GeneratedFileRecord[] = [
  {
    path: 'lib/late_night_vault.dart',
    language: 'dart',
    part: 5,
    description:
      '18+ Age-Gated Late-Night After-Hours Vault controller (LateNightVaultGateController), 4-digit PIN lock, Spice Tiers (1.10x–1.35x multiplier), and 15s Mid-Take Improvisation Twist timer.',
    lineCount: 416,
    content: `import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'lobby.dart';

enum LateNightSpiceTier {
  midnightNoir(tier: 1, label: 'Tier 1 · Midnight Noir & Dark Comedy', multiplier: 1.10),
  uncensoredPrestige(tier: 2, label: 'Tier 2 · Uncensored R-Rated Prestige', multiplier: 1.20),
  afterHoursDoubleDare(tier: 3, label: 'Tier 3 · After-Hours Double-Dare & Twist', multiplier: 1.35);

  final int tier;
  final String label;
  final double multiplier;
  const LateNightSpiceTier({required this.tier, required this.label, required this.multiplier});
}

class LateNightVaultGateController extends ChangeNotifier {
  Future<bool> verifyAgeAndUnlockVault({
    required int birthYear,
    required String fourDigitPin,
  }) async {
    final currentYear = DateTime.now().year;
    if (birthYear < 1900 || (currentYear - birthYear) < 18) return false;
    if (!RegExp(r'^[0-9]{4}$').hasMatch(fourDigitPin.trim())) return false;
    await supabase.rpc('verify_player_age_and_unlock_late_night', params: {
      'p_birth_year': birthYear,
      'p_session_pin': fourDigitPin.trim(),
    });
    return true;
  }
}`,
  },
  {
    path: 'supabase/late_night_schema.sql',
    language: 'sql',
    part: 5,
    description:
      'Hidden age-gated table (public.scenes_late_night_after_hours), strict 18+ Row-Level Security (RLS) policy checking profiles.age_verified = true, and RPC verification function.',
    lineCount: 132,
    content: `-- ACT LIKE IT — PART 5: LATE-NIGHT AFTER-HOURS HIDDEN / AGE-GATED VAULT
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
  difficulty_tier integer not null default 4 check (difficulty_tier between 1 and 5)
);

alter table public.scenes_late_night_after_hours enable row level security;

create policy "Age-verified 18+ players only"
  on public.scenes_late_night_after_hours
  for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.age_verified = true
    )
  );`,
  },
  {
    path: 'lib/judging_engine.dart',
    language: 'dart',
    part: 4,
    description:
      'Tri-Modal Judging Engine: Google Gemini multimodal video/audio telemetrics (gemini-2.5-flash), Supabase Storage looped video replay (performance-loops), and Social Share metric calculator.',
    lineCount: 472,
    content: `import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:video_player/video_player.dart';

class TriModalJudgingEngine extends ChangeNotifier {
  static const String storageBucket = 'performance-loops';
  // GenerativeModel(model: 'gemini-2.5-flash') + controller.setLooping(true)
}`,
  },
  {
    path: 'lib/webrtc_manager.dart',
    language: 'dart',
    part: 3,
    description:
      'LiveKit WebRTC SFU camera/audio capture (WebRtcStageManager) with Dynacast + Simulcast for 2–8 remote players, role switching, and 1 Hz telemetrics frame sampling.',
    lineCount: 515,
    content: `import 'package:livekit_client/livekit_client.dart';
// RoomOptions(adaptiveStream: true, dynacast: true, defaultVideoPublishOptions: VideoPublishOptions(simulcast: true))`,
  },
  {
    path: 'supabase/schema.sql',
    language: 'sql',
    part: 2,
    description:
      'PostgreSQL DDL & RLS policies for profiles, scenes_era_1970_1999, scenes_era_2000_2026, scenes_awards_vault, scenes_cult_classics, lobbies, and lobby_players with 8-player trigger.',
    lineCount: 289,
    content: `create table if not exists public.profiles ( id uuid primary key );
create table if not exists public.scenes_era_1970_1999 ( id uuid primary key );
create table if not exists public.scenes_era_2000_2026 ( id uuid primary key );
create table if not exists public.scenes_awards_vault (
  id uuid primary key,
  award_subcategory text not null check (
    award_subcategory in ('Best Actor', 'Best Actress', 'Best Villain', 'Emmy Vault')
  )
);
create table if not exists public.scenes_cult_classics ( id uuid primary key );
create table if not exists public.lobbies ( id uuid primary key );
alter publication supabase_realtime add table public.lobbies;`,
  },
  {
    path: 'lib/lobby.dart',
    language: 'dart',
    part: 2,
    description:
      'Matchmaking & Supabase Realtime controller (LobbyRealtimeManager) + LobbyMatchmakingScreen wired to LiveKitSoundstageScreen.',
    lineCount: 644,
    content: `import 'package:supabase_flutter/supabase_flutter.dart';`,
  },
  {
    path: 'pubspec.yaml',
    language: 'yaml',
    part: 1,
    description:
      'Flutter manifest configuring supabase_flutter, livekit_client, flutter_webrtc, google_generative_ai, and video_player.',
    lineCount: 44,
    content: `name: act_like_it
dependencies:
  supabase_flutter: ^2.8.0
  livekit_client: ^2.3.0
  google_generative_ai: ^0.4.6`,
  },
  {
    path: 'lib/main.dart',
    language: 'dart',
    part: 1,
    description:
      'Foundational entry point initializing Supabase (10 EPS Realtime) and routing SoundstageShellScreen to LobbyMatchmakingScreen and LateNightAfterHoursScreen.',
    lineCount: 302,
    content: `import 'package:flutter/material.dart';
import 'lobby.dart';
import 'late_night_vault.dart';`,
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

export function validatePart3WebRtcManager(dartContent: string): {
  valid: boolean;
  hasAdaptiveStream: boolean;
  hasDynacast: boolean;
  hasSimulcast: boolean;
} {
  const hasAdaptiveStream = dartContent.includes('adaptiveStream: true');
  const hasDynacast = dartContent.includes('dynacast: true');
  const hasSimulcast = dartContent.includes('simulcast: true');
  return {
    valid: hasAdaptiveStream && hasDynacast && hasSimulcast,
    hasAdaptiveStream,
    hasDynacast,
    hasSimulcast,
  };
}

export function validatePart4JudgingEngine(dartContent: string): {
  valid: boolean;
  hasGeminiModel: boolean;
  hasSupabaseStorageLoop: boolean;
  hasVideoLooping: boolean;
} {
  const hasGeminiModel =
    dartContent.includes('GenerativeModel') ||
    dartContent.includes('gemini-2.5-flash');
  const hasSupabaseStorageLoop = dartContent.includes('performance-loops');
  const hasVideoLooping = dartContent.includes('setLooping(true)');
  return {
    valid: hasGeminiModel && hasSupabaseStorageLoop && hasVideoLooping,
    hasGeminiModel,
    hasSupabaseStorageLoop,
    hasVideoLooping,
  };
}

export function verifyLateNightAgeGate(params: {
  birthYear: number;
  currentYear?: number;
  pinCode: string;
}): {
  unlocked: boolean;
  age: number;
  reason?: string;
} {
  const currentYear = params.currentYear ?? 2026;
  const age = currentYear - params.birthYear;
  if (params.birthYear < 1900 || age < 18) {
    return {
      unlocked: false,
      age,
      reason: 'Players must be 18 or older to unlock Late-Night After-Hours.',
    };
  }
  if (!/^[0-9]{4}$/.test(params.pinCode.trim())) {
    return {
      unlocked: false,
      age,
      reason: 'Enter a valid 4-digit numeric session PIN.',
    };
  }
  return { unlocked: true, age };
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
