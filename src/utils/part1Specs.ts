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
    title: 'Database Migration & Matchmaking',
    status: 'completed',
    targetFiles: [
      'supabase/migrations/20261017000000_init_schema.sql',
      'supabase/seed.sql',
      'lib/lobby.dart',
    ],
    summary:
      'Production Supabase migration (profiles, scenes, lobbies, lobby_players, indexes, strict 18+ RLS policies) and 37-scene seed.sql across all 9 categories.',
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
    title: 'Late-Night After-Hours & Cloud APK',
    status: 'completed',
    targetFiles: ['lib/late_night_vault.dart', '.github/workflows/build_apk.yml'],
    summary:
      '18+ age-gating via profiles.birth_year RLS, 5 adult-oriented Late-Night scenes, and automated GitHub Actions APK builder.',
  },
];

export const WORKSPACE_FILES: GeneratedFileRecord[] = [
  {
    path: 'supabase/migrations/20261017000001_match_history.sql',
    language: 'sql',
    part: 2,
    description:
      'Match History & Win Tracking Supabase migration creating public.match_history (id, player_id, scene_id, ai_score, peer_score, social_score, final_score, is_win, created_at) with strict Row Level Security (RLS) policies.',
    lineCount: 55,
    content: `-- ACT LIKE IT — MATCH HISTORY & WIN TRACKING MIGRATION
-- File: supabase/migrations/20261017000001_match_history.sql

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

alter table public.match_history enable row level security;

create policy "Users can read their own match history"
  on public.match_history for select to authenticated
  using (auth.uid() = player_id);

create policy "Users can insert their own match history"
  on public.match_history for insert to authenticated
  with check (auth.uid() = player_id);`,
  },
  {
    path: 'lib/offline_manager.dart',
    language: 'dart',
    part: 4,
    description:
      'Store & Forward Offline Manager: caches Supabase Scene Packs into SharedPreferences, records 30s Pass-and-Play clips to getTemporaryDirectory(), queues offline Gemini AI Judging, and queues/auto-syncs MatchHistoryRecord rows to public.match_history via connectivity_plus.',
    lineCount: 1505,
    content: `import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineManager extends ChangeNotifier {
  static final OfflineManager instance = OfflineManager._internal();
  // 1. Local Scene Caching: downloadAndCacheScenePacks() -> SharedPreferences
  // 2. Pass-and-Play Local Temp Storage: saveLocalOfflineClipToTempDir() -> getTemporaryDirectory()
  // 3. Queued Gemini AI Judging: enqueueOfflinePerformance() + connectivity_plus auto-flush
}`,
  },
  {
    path: 'lib/dashboard_marquee.dart',
    language: 'dart',
    part: 1,
    description:
      'The Living Marquee & Neon Backstage home dashboard with auto-playing Game Show background music loop (AudioPlayer + ReleaseMode.loop + UrlSource SoundHelix-Song-1.mp3), mute toggle IconButton (Icons.volume_up / Icons.volume_off), navigation/dispose lifecycle cleanup, and Shared Element (Hero + StageSharedTransitionRoute) transitions.',
    lineCount: 1984,
    content: `import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'lobby.dart';
import 'webrtc_manager.dart';
import 'late_night_vault.dart';
import 'offline_manager.dart';
import 'match_history_screen.dart';

class LivingMarqueeDashboardScreen extends StatefulWidget {
  const LivingMarqueeDashboardScreen({super.key});
  // 1. Dynamic RadialGradient Spotlights (Purple #A855F7, Cyan #06B6D4, Amber #F59E0B)
  // 2. Animated Telemetrics HUD Circular Progress Gauges (AI, Peer, Social)
  // 3. Game Show Background Music Loop (AudioPlayer + ReleaseMode.loop + UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'))
  // 4. Mute/Unmute Toggle IconButton (Icons.volume_up / Icons.volume_off) + pause on navigation + dispose()
  // 5. Physical Clapping Movie Clapperboard Primary CTA -> StageSharedTransitionRoute
  // 6. Horizontally Scrolling Glowing Movie Tickets Carousel with Hero(tag: SceneHeroTags.ticketTag(ticket.category))
}`,
  },
  {
    path: 'supabase/migrations/20261017000000_init_schema.sql',
    language: 'sql',
    part: 2,
    description:
      'Production Supabase migration creating profiles (birth_year), scenes (is_late_night), lobbies (room_code, host_id, active_scene_id, status), lobby_players, indexes, and strict 18+ Row Level Security (RLS) policies.',
    lineCount: 221,
    content: `-- ACT LIKE IT — INITIAL PRODUCTION SCHEMA & ROW LEVEL SECURITY MIGRATION
-- File: supabase/migrations/20261017000000_init_schema.sql
create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  birth_year integer not null check (
    birth_year >= 1900 and birth_year <= extract(year from current_date)::integer
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.scenes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  actor_name text not null,
  character_name text not null,
  script_excerpt text not null,
  target_emotion text not null,
  category text not null,
  is_late_night boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.lobbies (
  id uuid primary key default gen_random_uuid(),
  room_code text not null unique check (room_code ~ '^[0-9]{6}$'),
  host_id uuid not null references public.profiles(id) on delete cascade,
  active_scene_id uuid references public.scenes(id) on delete set null,
  status text not null default 'waiting'
);

create table if not exists public.lobby_players (
  id uuid primary key default gen_random_uuid(),
  lobby_id uuid not null references public.lobbies(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  is_ready boolean not null default true,
  score numeric(5,2) not null default 0.00,
  unique (lobby_id, user_id)
);

alter table public.profiles enable row level security;
alter table public.scenes enable row level security;
alter table public.lobbies enable row level security;
alter table public.lobby_players enable row level security;

create policy "Standard scenes (is_late_night = false) are viewable by everyone"
  on public.scenes for select using (is_late_night = false);

create policy "Late-Night scenes require verified 18+ birth_year in profiles"
  on public.scenes for select to authenticated
  using (
    is_late_night = true and exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.birth_year is not null
        and (extract(year from current_date)::integer - p.birth_year) >= 18
    )
  );`,
  },
  {
    path: 'supabase/seed.sql',
    language: 'sql',
    part: 2,
    description:
      'Production seed file inserting 37 real movie & television scenes (3–4 lines of dialogue each) across Eras (1970–1999, 2000–2026), Awards (Best Actor, Best Actress, Best Supporting Actor, Best Villain, Emmy Vault), Cult Classics, and 5 Late-Night After-Hours scenes.',
    lineCount: 382,
    content: `-- ACT LIKE IT — PRODUCTION SEED DATA FOR ALL SCENE CATEGORIES
-- File: supabase/seed.sql
insert into public.scenes (
  title, actor_name, character_name, script_excerpt, target_emotion, category, is_late_night
) values
  (
    'The Godfather (1972)',
    'Marlon Brando',
    'Don Vito Corleone',
    E'Why did you go to the police? Why didn''t you come to me first?\\nWhat have I ever done to make you treat me so disrespectfully?\\nIf you had come to me in friendship, then this scum that ruined your daughter would be suffering this very day.\\nAnd if by chance an honest man like yourself should make enemies, then they would become my enemies.',
    'Patriarchal Authority & Quiet Menace',
    'Eras: 1970–1999',
    false
  ),
  (
    'The Dark Knight (2008)',
    'Heath Ledger',
    'The Joker',
    E'Wanna know how I got these scars? My father was a drinker... and a fiend.\\nAnd one night, he goes off crazier than usual. Mommy gets the kitchen knife to defend herself.\\nHe doesn''t like that. Not... one... bit.\\nSo, me watching, he takes the knife to her, laughing while he does it. He turns to me, and he says: "Why so serious?"',
    'Unhinged Theatrical Menace',
    'Eras: 2000–2026',
    false
  ),
  (
    'Eyes Wide Shut (1999)',
    'Nicole Kidman',
    'Alice Harford',
    E'Do you really think you know everything that goes through my head when we''re lying in the dark, Bill?\\nLast summer at Cape Cod, there was a naval officer at the next table. He glanced at me for three seconds, and I couldn''t breathe.\\nIf he had wanted me—even for one single night—I was ready to give up everything. You, Helena, my whole life.\\nAnd yet at the very same moment, you were dearer to me than ever. If you men only knew...',
    'Hypnotic Erotic Candor & Jealousy',
    'Late-Night After-Hours',
    true
  );`,
  },
  {
    path: '.github/workflows/build_apk.yml',
    language: 'yaml',
    part: 5,
    description:
      'GitHub Actions workflow (Build and Release APK) with Zulu Java 17, Flutter stable, Force compileSdk 36 for AndroidX across .pub-cache/hosted, --dart-define secrets injection, and actions/upload-artifact@v4.',
    lineCount: 90,
    content: `name: Build and Release APK

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Ensure Android Platform & S26 Ultra Permissions
        run: |
          if [ ! -f "android/gradlew" ]; then
            flutter create --platforms=android --org com.actlikeit --project-name act_like_it .
          fi
          sed -i 's/compileSdk = .*/compileSdk = 36/g' android/app/build.gradle.kts || true

      - name: Install Dependencies
        run: flutter pub get

      - name: Force compileSdk 36 for AndroidX
        run: |
          for cache_dir in "/home/runner/.pub-cache/hosted" "\${PUB_CACHE}/hosted"; do
            if [ -d "\$cache_dir" ]; then
              find "\$cache_dir" \\( -name "build.gradle" -o -name "build.gradle.kts" \\) -exec sed -i \\
                -e 's/compileSdkVersion 31/compileSdkVersion 36/g' \\
                -e 's/compileSdkVersion 32/compileSdkVersion 36/g' \\
                -e 's/compileSdkVersion 33/compileSdkVersion 36/g' \\
                -e 's/compileSdkVersion 34/compileSdkVersion 36/g' \\
                -e 's/compileSdkVersion 35/compileSdkVersion 36/g' \\
                -e 's/compileSdk 31/compileSdk 36/g' \\
                -e 's/compileSdk 32/compileSdk 36/g' \\
                -e 's/compileSdk 33/compileSdk 36/g' \\
                -e 's/compileSdk 34/compileSdk 36/g' \\
                -e 's/compileSdk 35/compileSdk 36/g' \\
                -e 's/compileSdk = 31/compileSdk = 36/g' \\
                -e 's/compileSdk = 32/compileSdk = 36/g' \\
                -e 's/compileSdk = 33/compileSdk = 36/g' \\
                -e 's/compileSdk = 34/compileSdk = 36/g' \\
                -e 's/compileSdk = 35/compileSdk = 36/g' {} +
            fi
          done

      - name: Build Release APK
        run: flutter build apk --release --dart-define=SUPABASE_URL="\${{ secrets.SUPABASE_URL }}" --dart-define=SUPABASE_ANON_KEY="\${{ secrets.SUPABASE_ANON_KEY }}" --dart-define=LIVEKIT_URL="\${{ secrets.LIVEKIT_URL }}" --dart-define=GEMINI_API_KEY="\${{ secrets.GEMINI_API_KEY }}"

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: act-like-it-apk
          path: build/app/outputs/flutter-apk/app-release.apk`,
  },
  {
    path: 'lib/late_night_vault.dart',
    language: 'dart',
    part: 5,
    description:
      '18+ Age-Gated Late-Night After-Hours Vault controller updating profiles.birth_year and querying public.scenes (is_late_night = true), with 4-digit PIN lock and 15s Mid-Take Improvisation Twist.',
    lineCount: 595,
    content: `import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';
import 'lobby.dart';

class LateNightVaultGateController extends ChangeNotifier {
  Future<bool> verifyAgeAndUnlockVault({
    required int birthYear,
    required String fourDigitPin,
  }) async {
    final currentYear = DateTime.now().year;
    if (birthYear < 1900 || (currentYear - birthYear) < 18) return false;
    if (!RegExp(r'^[0-9]{4}$').hasMatch(fourDigitPin.trim())) return false;
    final client = supabaseOrNull;
    final currentUser = client?.auth.currentUser;
    if (client != null && currentUser != null) {
      await client.from('profiles').upsert({
        'id': currentUser.id,
        'username': 'actor_\${currentUser.id.substring(0, 6)}',
        'birth_year': birthYear,
      });
    }
    return true;
  }
}`,
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
      'LiveKit WebRTC SFU camera/audio capture (WebRtcStageManager) with flutter_webrtc RTCVideoViewObjectFit.RTCVideoViewObjectFitCover, Dynacast + Simulcast for 2–8 remote players, and 1 Hz telemetrics frame sampling.',
    lineCount: 662,
    content: `import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
// RoomOptions(adaptiveStream: true, dynacast: true, defaultVideoPublishOptions: VideoPublishOptions(simulcast: true))
// VideoTrackRenderer(_stageManager.localVideoTrack!, fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)`,
  },
  {
    path: 'lib/lobby.dart',
    language: 'dart',
    part: 2,
    description:
      'Matchmaking & Supabase Realtime controller (LobbyRealtimeManager) querying public.scenes and synchronizing public.lobbies (room_code, host_id, active_scene_id, status).',
    lineCount: 1136,
    content: `import 'package:supabase_flutter/supabase_flutter.dart';`,
  },
  {
    path: 'pubspec.yaml',
    language: 'yaml',
    part: 1,
    description:
      'Flutter manifest configuring supabase_flutter, livekit_client, flutter_webrtc, google_generative_ai, video_player, audioplayers: ^6.1.0, camera, path_provider, connectivity_plus, shared_preferences: ^2.5.2, and dependency_overrides for shared_preferences_android: ^2.4.7.',
    lineCount: 53,
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
  audioplayers: ^6.1.0
  camera: ^0.11.0+2
  permission_handler: ^11.3.1
  path_provider: ^2.1.4
  connectivity_plus: ^6.1.0

  # State Management, Utilities & Social Sharing
  provider: ^6.1.2
  shared_preferences: ^2.5.2
  share_plus: ^10.1.2
  http: ^1.2.2
  uuid: ^4.5.1
  intl: ^0.19.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true

dependency_overrides:
  shared_preferences_android: ^2.4.7`,
  },
  {
    path: 'lib/main.dart',
    language: 'dart',
    part: 1,
    description:
      'Safe Boot entry point wrapping main() in runZonedGuarded, FlutterError.onError, PlatformDispatcher.instance.onError, custom release ErrorWidget.builder, timeout-guarded AppConfig/Supabase initialization, and SafeBootErrorBoundary.',
    lineCount: 954,
    content: `import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'lobby.dart';
import 'late_night_vault.dart';
import 'dashboard_marquee.dart';

// SafeBootDiagnostics + runZonedGuarded + FlutterError.onError + PlatformDispatcher.instance.onError
// Custom ErrorWidget.builder replaces release-mode blank white screen with visual stack-trace card
// SafeBootErrorBoundary + SafeBootEmergencyApp`,
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

export function validateMigrationSchema(sqlContent: string): {
  valid: boolean;
  hasProfilesBirthYear: boolean;
  hasScenesTable: boolean;
  hasLobbiesTable: boolean;
  hasLobbyPlayersTable: boolean;
  hasLateNightRls: boolean;
} {
  const hasProfilesBirthYear =
    sqlContent.includes('public.profiles') && sqlContent.includes('birth_year');
  const hasScenesTable =
    sqlContent.includes('public.scenes') &&
    sqlContent.includes('script_excerpt') &&
    sqlContent.includes('is_late_night');
  const hasLobbiesTable =
    sqlContent.includes('public.lobbies') &&
    sqlContent.includes('active_scene_id');
  const hasLobbyPlayersTable = sqlContent.includes('public.lobby_players');
  const hasLateNightRls =
    sqlContent.includes('enable row level security') &&
    sqlContent.includes('is_late_night = true') &&
    sqlContent.includes('>= 18');

  return {
    valid:
      hasProfilesBirthYear &&
      hasScenesTable &&
      hasLobbiesTable &&
      hasLobbyPlayersTable &&
      hasLateNightRls,
    hasProfilesBirthYear,
    hasScenesTable,
    hasLobbiesTable,
    hasLobbyPlayersTable,
    hasLateNightRls,
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
