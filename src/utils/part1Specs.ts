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
    status: 'pending',
    targetFiles: ['supabase/late_night_schema.sql', 'lib/late_night_vault.dart'],
    summary:
      'Secure age-gating, RLS policies, mechanics, and prompt structures for the hidden Late-Night After-Hours table.',
  },
];

export const WORKSPACE_FILES: GeneratedFileRecord[] = [
  {
    path: 'lib/judging_engine.dart',
    language: 'dart',
    part: 4,
    description:
      'Tri-Modal Judging Engine: Google Gemini multimodal video/audio telemetrics (gemini-2.5-flash), Supabase Storage looped video replay (performance-loops), and Social Share metric calculator.',
    lineCount: 472,
    content: `import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';
import 'lobby.dart';
import 'webrtc_manager.dart';

class TriModalJudgingEngine extends ChangeNotifier {
  static const String storageBucket = 'performance-loops';

  Future<AiTelemetricsReport> evaluatePerformanceWithGemini({
    required ScenePrompt scene,
    required List<TelemetricsFrameSample> samples,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.2,
      ),
    );
    // Evaluates facial_expression_score, vocal_cadence_score, director_cue_fidelity
  }

  Future<String> uploadAndStartSupabaseVideoLoop({
    required String roomCode,
    required String userId,
    required int roundNumber,
    Uint8List? recordedMp4Bytes,
  }) async {
    // Uploads to supabase.storage.from('performance-loops') and sets controller.setLooping(true)
  }
}`,
  },
  {
    path: 'lib/webrtc_manager.dart',
    language: 'dart',
    part: 3,
    description:
      'LiveKit WebRTC SFU camera/audio capture (WebRtcStageManager) with Dynacast + Simulcast for 2–8 remote players, role switching, and 1 Hz telemetrics frame sampling.',
    lineCount: 515,
    content: `import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';
import 'lobby.dart';
import 'judging_engine.dart';

enum SfuParticipantRole {
  activePerformer,
  remoteSpectator,
}

class WebRtcStageManager extends ChangeNotifier {
  Future<void> connectToSfuStage({
    required String roomName,
    required String participantIdentity,
    required String participantName,
    required SfuParticipantRole initialRole,
  }) async {
    final roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
      defaultVideoPublishOptions: const VideoPublishOptions(simulcast: true),
    );
  }
}`,
  },
  {
    path: 'supabase/schema.sql',
    language: 'sql',
    part: 2,
    description:
      'PostgreSQL DDL & RLS policies for profiles, scenes_era_1970_1999, scenes_era_2000_2026, scenes_awards_vault, scenes_cult_classics, lobbies, and lobby_players with 8-player trigger.',
    lineCount: 289,
    content: `-- ACT LIKE IT — PART 2: SUPABASE POSTGRESQL SCHEMA & REALTIME MATCHMAKING
create table if not exists public.profiles ( id uuid primary key );
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
    content: `import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'webrtc_manager.dart';`,
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
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.0
  livekit_client: ^2.3.0
  flutter_webrtc: ^0.12.0
  google_generative_ai: ^0.4.6
  video_player: ^2.9.2`,
  },
  {
    path: 'lib/main.dart',
    language: 'dart',
    part: 1,
    description:
      'Foundational entry point initializing Supabase (10 EPS Realtime) and routing SoundstageShellScreen to LobbyMatchmakingScreen.',
    lineCount: 294,
    content: `import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lobby.dart';`,
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
    dartContent.includes('GenerativeModel') &&
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

/**
 * Computes the Tri-Modal Composite Score matching TriModalJudgingEngine in lib/judging_engine.dart:
 * 45% AI Telemetrics + 35% Remote Peer Judging + 20% Social Share Judging.
 */
export function calculateTriModalCompositeScore(params: {
  facialExpression: number;
  vocalCadence: number;
  directorCueFidelity: number;
  peerVoteScore: number;
  externalShares: number;
  externalReactions: number;
  loopCompletions: number;
}): {
  aiScore: number;
  peerScore: number;
  socialScore: number;
  compositeScore: number;
} {
  const aiScore = Math.min(
    100,
    Math.max(
      0,
      (params.facialExpression +
        params.vocalCadence +
        params.directorCueFidelity) /
        3
    )
  );
  const peerScore = Math.min(100, Math.max(0, params.peerVoteScore));
  const weightedEngagement =
    params.externalShares * 4 +
    params.externalReactions * 2 +
    params.loopCompletions;
  const socialScore =
    weightedEngagement <= 0
      ? 0
      : Math.min(100, Math.max(0, 25 * Math.log(1 + weightedEngagement)));

  const compositeScore =
    aiScore * 0.45 + peerScore * 0.35 + socialScore * 0.2;

  return {
    aiScore: Number(aiScore.toFixed(1)),
    peerScore: Number(peerScore.toFixed(1)),
    socialScore: Number(socialScore.toFixed(1)),
    compositeScore: Number(compositeScore.toFixed(1)),
  };
}

export function calculateSfuBandwidthSavings(
  playerCount: number,
  role: 'activePerformer' | 'remoteSpectator'
): {
  clampedPlayers: number;
  sfuUpstreamKbps: number;
  sfuDownstreamKbps: number;
  p2pUpstreamKbps: number;
  bandwidthSavedPercent: number;
} {
  const clampedPlayers = Math.max(2, Math.min(8, Math.round(playerCount)));
  const streamBitrateKbps = 1500;
  const p2pUpstreamKbps = (clampedPlayers - 1) * streamBitrateKbps;
  const sfuUpstreamKbps = role === 'activePerformer' ? streamBitrateKbps : 32;
  const sfuDownstreamKbps = streamBitrateKbps;
  const bandwidthSavedPercent = Math.round(
    ((p2pUpstreamKbps - sfuUpstreamKbps) / p2pUpstreamKbps) * 100
  );

  return {
    clampedPlayers,
    sfuUpstreamKbps,
    sfuDownstreamKbps,
    p2pUpstreamKbps,
    bandwidthSavedPercent,
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
