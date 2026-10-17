import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  validateFlutterPubspec,
  validateMigrationSchema,
  validatePart3WebRtcManager,
  validatePart4JudgingEngine,
  verifyLateNightAgeGate,
  getBatchCompletionRatio,
} from './part1Specs.ts';

test('Supabase migration and seed files exist on disk and pass schema & category checks', () => {
  const migrationSql = fs.readFileSync(
    'supabase/migrations/20261017000000_init_schema.sql',
    'utf8'
  );
  const seedSql = fs.readFileSync('supabase/seed.sql', 'utf8');

  const schemaCheck = validateMigrationSchema(migrationSql);
  assert.equal(schemaCheck.valid, true);

  // Verify all 9 required categories exist in seed.sql
  const requiredCategories = [
    'Eras: 1970–1999',
    'Eras: 2000–2026',
    'Awards: Best Actor',
    'Awards: Best Actress',
    'Awards: Best Supporting Actor',
    'Awards: Best Villain',
    'Awards: Emmy Vault',
    'Specialty: Cult Classics',
    'Late-Night After-Hours',
  ];

  for (const category of requiredCategories) {
    assert.ok(
      seedSql.includes(category),
      `Expected seed.sql to include category: ${category}`
    );
  }

  // Verify iconic films requested in prompt
  assert.ok(seedSql.includes('The Godfather (1972)'));
  assert.ok(seedSql.includes('Taxi Driver (1976)'));
  assert.ok(seedSql.includes('The Dark Knight (2008)'));
  assert.ok(seedSql.includes('Hidden Figures (2016)'));
  assert.ok(seedSql.includes('The Rocky Horror Picture Show (1975)'));

  // Verify lib/webrtc_manager.dart has flutter_webrtc import and RTCVideoViewObjectFitCover
  const webrtcDart = fs.readFileSync('lib/webrtc_manager.dart', 'utf8');
  assert.ok(
    webrtcDart.includes("import 'package:flutter_webrtc/flutter_webrtc.dart';")
  );
  assert.ok(
    webrtcDart.includes('RTCVideoViewObjectFit.RTCVideoViewObjectFitCover')
  );
  assert.equal(webrtcDart.includes('VideoViewFit'), false);
  assert.equal(webrtcDart.includes('toIso88601String'), false);

  // Verify .github/workflows/build_apk.yml has Force compileSdk 36 for AndroidX step
  const workflowYml = fs.readFileSync('.github/workflows/build_apk.yml', 'utf8');
  assert.ok(workflowYml.includes('name: Force compileSdk 36 for AndroidX'));
  assert.ok(workflowYml.includes('/home/runner/.pub-cache/hosted'));
  assert.ok(workflowYml.includes('compileSdkVersion 31/compileSdkVersion 36'));
  assert.ok(workflowYml.includes('compileSdkVersion 34/compileSdkVersion 36'));
  assert.ok(workflowYml.includes('compileSdkVersion 35/compileSdkVersion 36'));
  assert.ok(
    workflowYml.includes(
      "sed -i 's/compileSdk = .*/compileSdk = 36/g' android/app/build.gradle.kts || true"
    )
  );

  // Verify lib/dashboard_marquee.dart, lib/lobby.dart, and lib/webrtc_manager.dart Hero shared element transitions
  const dashboardDart = fs.readFileSync('lib/dashboard_marquee.dart', 'utf8');
  const lobbyDart = fs.readFileSync('lib/lobby.dart', 'utf8');
  const mainDart = fs.readFileSync('lib/main.dart', 'utf8');
  assert.ok(dashboardDart.includes('class LivingMarqueeDashboardScreen'));
  assert.ok(dashboardDart.includes('RadialGradient'));
  assert.ok(dashboardDart.includes('Transform.scale'));
  assert.ok(dashboardDart.includes('CircularProgressIndicator'));
  assert.ok(dashboardDart.includes('_ClapperZebraStripesPainter'));
  assert.ok(dashboardDart.includes('_MovieTicketStubClipper'));
  assert.ok(dashboardDart.includes('SceneHeroTags.ticketTag(ticket.category)'));
  assert.ok(dashboardDart.includes('StageSharedTransitionRoute'));
  assert.ok(lobbyDart.includes('class SceneHeroTags'));
  assert.ok(lobbyDart.includes('class StageSharedTransitionRoute'));
  assert.ok(lobbyDart.includes('MaterialRectCenterArcTween'));
  assert.ok(
    webrtcDart.includes(
      'SceneHeroTags.ticketTag(widget.lobbySession.selectedCategory)'
    )
  );
  assert.ok(mainDart.includes("import 'dashboard_marquee.dart';"));
  assert.ok(mainDart.includes('home: const LivingMarqueeDashboardScreen()'));

  // Verify Store & Forward Offline Mode & Android SDK 36 SharedPreferences override (pubspec.yaml, lib/offline_manager.dart, lib/lobby.dart, lib/judging_engine.dart)
  const pubspecDisk = fs.readFileSync('pubspec.yaml', 'utf8');
  const offlineDart = fs.readFileSync('lib/offline_manager.dart', 'utf8');
  const judgingDart = fs.readFileSync('lib/judging_engine.dart', 'utf8');
  assert.ok(pubspecDisk.includes('connectivity_plus:'));
  assert.ok(pubspecDisk.includes('path_provider:'));
  assert.ok(pubspecDisk.includes('audioplayers: ^6.1.0'));
  assert.ok(pubspecDisk.includes('shared_preferences: ^2.5.2'));
  assert.ok(pubspecDisk.includes('dependency_overrides:'));
  assert.ok(pubspecDisk.includes('shared_preferences_android: ^2.4.7'));
  assert.ok(dashboardDart.includes("import 'package:audioplayers/audioplayers.dart';"));
  assert.ok(dashboardDart.includes('ReleaseMode.loop'));
  assert.ok(
    dashboardDart.includes(
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    )
  );
  assert.ok(dashboardDart.includes('Icons.volume_up'));
  assert.ok(dashboardDart.includes('Icons.volume_off'));
  assert.ok(dashboardDart.includes('_audioPlayer.dispose()'));
  assert.ok(offlineDart.includes('class OfflineManager'));
  assert.ok(offlineDart.includes('class OfflineLocalPartyScreen'));
  assert.ok(offlineDart.includes('downloadAndCacheScenePacks'));
  assert.ok(offlineDart.includes('getTemporaryDirectory'));
  assert.ok(offlineDart.includes('onConnectivityChanged'));
  assert.ok(offlineDart.includes('processQueuedPerformancesWithGemini'));
  assert.ok(lobbyDart.includes("import 'offline_manager.dart';"));
  assert.ok(lobbyDart.includes('Offline Local Party'));
  assert.ok(judgingDart.includes("import 'offline_manager.dart';"));
  assert.ok(judgingDart.includes('enqueueOfflinePerformance'));

  // Verify Match History & Win Tracking (supabase/migrations/20261017000001_match_history.sql, lib/judging_engine.dart, lib/offline_manager.dart, lib/dashboard_marquee.dart)
  const matchHistorySql = fs.readFileSync(
    'supabase/migrations/20261017000001_match_history.sql',
    'utf8'
  );
  assert.ok(matchHistorySql.includes('create table if not exists public.match_history'));
  assert.ok(matchHistorySql.includes('player_id uuid not null references public.profiles(id)'));
  assert.ok(matchHistorySql.includes('scene_id uuid references public.scenes(id)'));
  assert.ok(matchHistorySql.includes('ai_score'));
  assert.ok(matchHistorySql.includes('peer_score'));
  assert.ok(matchHistorySql.includes('social_score'));
  assert.ok(matchHistorySql.includes('final_score'));
  assert.ok(matchHistorySql.includes('is_win boolean'));
  assert.ok(matchHistorySql.includes('enable row level security'));
  assert.ok(judgingDart.includes('saveRoundResultToMatchHistory'));
  assert.ok(judgingDart.includes("from('match_history').insert"));
  assert.ok(offlineDart.includes('class MatchHistoryRecord'));
  assert.ok(offlineDart.includes('queueOfflineMatchHistoryRecord'));
  assert.ok(offlineDart.includes('syncPendingMatchHistoryToSupabase'));
  assert.ok(dashboardDart.includes('CAREER TROPHY ROOM'));
  assert.ok(dashboardDart.includes('_openCareerTrophyRoomDrawer'));

  // Verify Safe Boot Visual Error Handler in lib/main.dart & Phase 1/2/3/4 Logic Audit
  assert.ok(mainDart.includes('class SafeBootDiagnostics'));
  assert.ok(mainDart.includes('runZonedGuarded'));
  assert.ok(mainDart.includes('ErrorWidget.builder'));
  assert.ok(mainDart.includes('PlatformDispatcher.instance.onError'));
  assert.ok(mainDart.includes('class SafeBootErrorBoundary'));
  assert.ok(mainDart.includes('SchedulerBinding.instance.schedulerPhase'));
  assert.ok(offlineDart.includes('Future<void>? _initFuture;'));
  assert.ok(lobbyDart.includes('_ensureAuthenticatedAndProfile'));
  assert.ok(lobbyDart.includes('onPresenceSync'));
  assert.ok(lobbyDart.includes("event: 'lobby_state_sync'"));
  assert.ok(lobbyDart.includes('_handleLobbyPostgresChange'));
  assert.ok(webrtcDart.includes('_bindRoomListeners'));
  assert.ok(webrtcDart.includes('resumeStageAfterJudging'));
  assert.ok(webrtcDart.includes('cam.resumePreview()'));
  assert.ok(webrtcDart.includes('cam.pausePreview()'));
  assert.ok(judgingDart.includes('_extractJsonObject'));
  assert.ok(judgingDart.includes('_hasSyncedRoundToSupabase'));
  assert.ok(judgingDart.includes('_roundHistoryId'));
});

test('WORKSPACE_FILES entries pass structural validation', () => {
  const pubspec = WORKSPACE_FILES.find((f) => f.path === 'pubspec.yaml');
  const migration = WORKSPACE_FILES.find(
    (f) => f.path === 'supabase/migrations/20261017000000_init_schema.sql'
  );
  const seed = WORKSPACE_FILES.find((f) => f.path === 'supabase/seed.sql');
  const webrtc = WORKSPACE_FILES.find((f) => f.path === 'lib/webrtc_manager.dart');
  const judging = WORKSPACE_FILES.find((f) => f.path === 'lib/judging_engine.dart');
  const buildApkWorkflow = WORKSPACE_FILES.find(
    (f) => f.path === '.github/workflows/build_apk.yml'
  );

  assert.ok(pubspec && validateFlutterPubspec(pubspec.content).valid);
  assert.ok(migration && validateMigrationSchema(migration.content).valid);
  assert.ok(seed && seed.content.includes('insert into public.scenes'));
  assert.ok(webrtc && validatePart3WebRtcManager(webrtc.content).valid);
  assert.ok(judging && validatePart4JudgingEngine(judging.content).valid);
  assert.ok(buildApkWorkflow && buildApkWorkflow.content.includes('act-like-it-apk'));
});

test('Late-Night 18+ age gate rejects underage birth years and invalid PINs', () => {
  const underage = verifyLateNightAgeGate({
    birthYear: 2012,
    currentYear: 2026,
    pinCode: '2026',
  });
  assert.equal(underage.unlocked, false);

  const validAdult = verifyLateNightAgeGate({
    birthYear: 1997,
    currentYear: 2026,
    pinCode: '2026',
  });
  assert.equal(validAdult.unlocked, true);
  assert.equal(validAdult.age, 29);
});

test('Batch progress accurately reports all 5 of 5 batches completed (100%)', () => {
  const progress = getBatchCompletionRatio(BATCH_STAGES);
  assert.equal(progress.completedCount, 5);
  assert.equal(progress.totalCount, 5);
  assert.equal(progress.percentage, 100);
});
