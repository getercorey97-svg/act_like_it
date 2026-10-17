export interface BatchStage {
  part: number;
  title: string;
  status: 'completed' | 'pending';
  targetFiles: string[];
  summary: string;
}

export interface GeneratedFileRecord {
  path: string;
  language: 'yaml' | 'dart';
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
    status: 'pending',
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

export const PART_1_FILES: GeneratedFileRecord[] = [
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

  # Backend, PostgreSQL Database, Realtime State Sync & Edge Storage
  supabase_flutter: ^2.8.0

  # Real-Time Video/Audio WebRTC SFU Routing (2-8 Remote Players)
  livekit_client: ^2.3.0
  flutter_webrtc: ^0.12.0

  # Multimodal AI Telemetrics Judging (Video/Audio Frame Evaluation)
  google_generative_ai: ^0.4.6

  # Media Playback, Camera Capture & Device Permissions
  video_player: ^2.9.2
  camera: ^0.11.0+2
  permission_handler: ^11.3.1
  path_provider: ^2.1.5

  # State Management, Utilities & Social Sharing
  provider: ^6.1.2
  shared_preferences: ^2.3.2
  share_plus: ^10.1.2
  http: ^1.2.2
  uuid: ^4.5.1
  intl: ^0.19.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true`,
  },
  {
    path: 'lib/main.dart',
    language: 'dart',
    part: 1,
    description:
      'Foundational entry point initializing WidgetsFlutterBinding, portrait orientation lock, Supabase client with 10 EPS Realtime, and the SoundstageShellScreen.',
    lineCount: 288,
    content: `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-supabase-anon-key',
  );
  static const String liveKitUrl = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: 'wss://act-like-it-sfu.livekit.cloud',
  );
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
}

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
}

final SupabaseClient supabase = Supabase.instance.client;`,
  },
  {
    path: 'analysis_options.yaml',
    language: 'yaml',
    part: 1,
    description: 'Flutter linter rules enforcing const constructors and safe async context handling.',
    lineCount: 9,
    content: `include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: false
    use_build_context_synchronously: true
    prefer_final_fields: true`,
  },
];

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
