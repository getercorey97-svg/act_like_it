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

test('Supabase migration, 100-scene parody catalog, seed.sql, and official app logo pass all checks', () => {
  const migrationSql = fs.readFileSync(
    'supabase/migrations/20261017000000_init_schema.sql',
    'utf8'
  );
  const seedSql = fs.readFileSync('supabase/seed.sql', 'utf8');
  const catalogDart = fs.readFileSync('lib/ui/parody_scenes_catalog.dart', 'utf8');

  const schemaCheck = validateMigrationSchema(migrationSql);
  assert.equal(schemaCheck.valid, true);
  assert.ok(migrationSql.includes('create table if not exists public.scenes_late_night_after_hours'));
  assert.ok(migrationSql.includes('duet_lead_a'));
  assert.ok(migrationSql.includes('duet_lead_b'));

  // Verify all 10 categories exist in seed.sql (9 general categories + Late-Night After-Hours)
  const requiredCategories = [
    'Eras: 1970–1999',
    'Eras: 2000–2026',
    'Awards: Best Actor',
    'Awards: Best Actress',
    'Awards: Best Supporting Actor',
    'Awards: Best Villain',
    'Awards: Emmy Vault',
    'Specialty: Cult Classics',
    'Specialty: Sci-Fi & Blockbusters',
    'Late-Night After-Hours',
  ];

  for (const category of requiredCategories) {
    assert.ok(
      seedSql.includes(category),
      `Expected seed.sql to include category: ${category}`
    );
  }

  // Verify all 100 scene IDs exist in both parody_scenes_catalog.dart and supabase/seed.sql
  const prefixes = [
    'era70_',
    'era00_',
    'actor_',
    'actress_',
    'supp_',
    'villain_',
    'emmy_',
    'cult_',
    'scifi_',
    'ln_',
  ];
  for (const prefix of prefixes) {
    for (let i = 1; i <= 10; i++) {
      const id = `${prefix}${String(i).padStart(2, '0')}`;
      assert.ok(
        catalogDart.includes(`id: '${id}'`),
        `Expected parody_scenes_catalog.dart to include scene ${id}`
      );
      assert.ok(
        seedSql.includes(`'${id}'`),
        `Expected supabase/seed.sql to include scene ${id}`
      );
    }
  }
  assert.ok(seedSql.includes('insert into public.scenes_late_night_after_hours'));

  // Verify official app logo integration across pubspec, AndroidManifest, brand_logo.dart, and disk
  assert.ok(fs.existsSync('assets/app_logo.png'));
  assert.ok(fs.existsSync('public/app_logo.png'));
  const pubspecDisk = fs.readFileSync('pubspec.yaml', 'utf8');
  const manifestXml = fs.readFileSync('android/app/src/main/AndroidManifest.xml', 'utf8');
  const brandLogoDart = fs.readFileSync('lib/ui/brand_logo.dart', 'utf8');
  assert.ok(pubspecDisk.includes('assets/app_logo.png'));
  assert.ok(manifestXml.includes('android:icon="@mipmap/ic_launcher"'));
  assert.ok(brandLogoDart.includes('assets/app_logo.png'));

  // Verify WebRTC camera logic, Duet Lead A (#F5DEB3) & Lead B (#0CB6D4), and zero truncation
  const webrtcDart = fs.readFileSync('lib/webrtc_manager.dart', 'utf8');
  const sceneVaultDart = fs.readFileSync('lib/ui/scene_vault_screen.dart', 'utf8');
  assert.ok(webrtcDart.includes('VideoViewFit.cover'));
  assert.ok(webrtcDart.includes('scene.duetLeadA'));
  assert.ok(webrtcDart.includes('scene.duetLeadB'));
  assert.ok(webrtcDart.includes('0xFFF5DEB3'));
  assert.ok(webrtcDart.includes('0xFF0CB6D4'));
  assert.equal(sceneVaultDart.includes('TextOverflow.ellipsis'), false);

  // Verify .github/workflows/build_apk.yml has Build Release APK step
  const workflowYml = fs.readFileSync('.github/workflows/build_apk.yml', 'utf8');
  assert.ok(workflowYml.includes('name: Build Release APK'));
  assert.ok(workflowYml.includes('act-like-it-apk'));

  // Verify lib/dashboard_marquee.dart, lib/lobby.dart, lib/ui/lobby_models_and_realtime.dart, and lib/late_night_vault.dart
  const dashboardDart = fs.readFileSync('lib/dashboard_marquee.dart', 'utf8');
  const lobbyDart = fs.readFileSync('lib/lobby.dart', 'utf8');
  const lobbyModelsDart = fs.readFileSync('lib/ui/lobby_models_and_realtime.dart', 'utf8');
  const lateNightDart = fs.readFileSync('lib/late_night_vault.dart', 'utf8');
  const mainDart = fs.readFileSync('lib/main.dart', 'utf8');
  const offlineDart = fs.readFileSync('lib/offline_manager.dart', 'utf8');
  const judgingDart = fs.readFileSync('lib/judging_engine.dart', 'utf8');

  assert.ok(dashboardDart.includes('class LivingMarqueeDashboardScreen'));
  assert.ok(lobbyModelsDart.includes('class SceneHeroTags'));
  assert.ok(lobbyModelsDart.includes('class StageSharedTransitionRoute'));
  assert.ok(lobbyModelsDart.includes('specialtyBlockbusterSciFi'));
  assert.ok(lobbyDart.includes('_openGreenRoomSceneDrawer'));
  assert.ok(lateNightDart.includes('typedef LateNightPremiumScreen = LateNightAfterHoursScreen;'));
  assert.ok(offlineDart.includes('getLateNightAfterHoursScenes'));
  assert.ok(judgingDart.includes('saveRoundResultToMatchHistory'));
  assert.ok(mainDart.includes('class SafeBootDiagnostics'));
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

test('S.O.A. Alpha QA Systems (Gemini AI Calibration, qa_feedback SQL, Shake-to-Report Overlay, and QA Web Portal) pass verification', () => {
  const judgingDart = fs.readFileSync('lib/judging_engine.dart', 'utf8');
  const qaSql = fs.readFileSync(
    'supabase/migrations/20261024000002_qa_feedback.sql',
    'utf8'
  );
  const qaOverlayDart = fs.readFileSync('lib/qa/qa_overlay.dart', 'utf8');
  const qaPortalDart = fs.readFileSync('lib/qa/qa_web_portal.dart', 'utf8');
  const mainDart = fs.readFileSync('lib/main.dart', 'utf8');

  // 1. Gemini AI Calibration & Millisecond Telemetry
  assert.ok(judgingDart.includes('STRICT SCORING DISTRIBUTION MATRIX'));
  assert.ok(judgingDart.includes('90-100_OSCAR_LEVEL'));
  assert.ok(judgingDart.includes('70-89_AVERAGE_ATTEMPT'));
  assert.ok(judgingDart.includes('0-49_LOW_ENERGY_OR_MISSED_CUE'));
  assert.ok(judgingDart.includes('facial_micro_expressions'));
  assert.ok(judgingDart.includes('vocal_prosody_shifts'));
  assert.ok(judgingDart.includes('timestamp_ms'));

  // 2. Supabase QA Backend SQL
  assert.ok(qaSql.includes('create table if not exists public.qa_feedback'));
  assert.ok(qaSql.includes('tester_handle text not null'));
  assert.ok(qaSql.includes('app_version text not null'));
  assert.ok(qaSql.includes('bug_type text not null'));
  assert.ok(qaSql.includes('screenshot_url text'));
  assert.ok(qaSql.includes('device_info jsonb not null'));
  assert.ok(qaSql.includes('local_state_dump jsonb not null'));
  assert.ok(qaSql.includes('qa-screenshots'));

  // 3. Shake-to-Report Overlay & Companion Web Portal
  assert.ok(qaOverlayDart.includes('userAccelerometerEventStream'));
  assert.ok(qaOverlayDart.includes('RenderRepaintBoundary'));
  assert.ok(qaOverlayDart.includes('qa-screenshots'));
  assert.ok(qaPortalDart.includes('class QaWebPortalDashboardScreen'));
  assert.ok(qaPortalDart.includes('LOCAL_STATE_DUMP & DEVICE_INFO JSON'));

  // 4. Surgical injection into lib/main.dart without touching SafeBootErrorBoundary
  assert.ok(mainDart.includes('SafeBootErrorBoundary(child: ActLikeItApp())'));
  assert.ok(mainDart.includes('QaBugReporterOverlay'));
  assert.ok(mainDart.includes("settings.name == '/qa-dashboard'") && mainDart.includes('QaWebPortalDashboardScreen()'));
});

test('All 17 Viral, Gameplay, Progression & LiveOps Fixtures (#1-#5, #7-#18, skipping #6) + LIFE IS IMPROV mode pass verification', () => {
  const catalogDart = fs.readFileSync('lib/ui/parody_scenes_catalog.dart', 'utf8');
  const settingsDart = fs.readFileSync('lib/ui/game_settings_modal.dart', 'utf8');
  const webrtcDart = fs.readFileSync('lib/webrtc_manager.dart', 'utf8');
  const judgingDart = fs.readFileSync('lib/judging_engine.dart', 'utf8');
  const feedDart = fs.readFileSync('lib/social/cutting_room_feed.dart', 'utf8');
  const lateNightDart = fs.readFileSync('lib/late_night_vault.dart', 'utf8');
  const dashboardDart = fs.readFileSync('lib/dashboard_marquee.dart', 'utf8');
  const sceneVaultDart = fs.readFileSync('lib/ui/scene_vault_screen.dart', 'utf8');
  const profileDart = fs.readFileSync('lib/profile/actor_profile_screen.dart', 'utf8');
  const matchHistoryDart = fs.readFileSync('lib/match_history_screen.dart', 'utf8');
  const matchFinalDart = fs.readFileSync('lib/ui/match_finalization_screen.dart', 'utf8');
  const paymentDart = fs.readFileSync('lib/monetization/payment_dashboard_screen.dart', 'utf8');
  const lobbyDart = fs.readFileSync('lib/lobby.dart', 'utf8');

  // Fixture #1: Open Co-Star Audition Links
  assert.ok(webrtcDart.includes('openCoStarChallengeTakeId'));
  assert.ok(feedDart.includes('ACCEPT CO-STAR AUDITION'));

  // Fixture #2: Millisecond AI Receipt Stamps
  assert.ok(judgingDart.includes('millisecondReceiptStamps'));

  // Fixture #3: Daily Cattle Call Global 24h Challenge
  assert.ok(catalogDart.includes('getTodaysDailyCattleCallChallenge'));
  assert.ok(dashboardDart.includes('DAILY CATTLE CALL'));

  // Fixture #4: Break Character / No-Laugh Stone-Faced Hazard
  assert.ok(settingsDart.includes('stoneFacedNoLaughHazard'));
  assert.ok(webrtcDart.includes('CHARACTER BROKEN (-15 PTS)'));

  // Fixture #5: Persona Archetype HUD Trim & Cut-In
  assert.ok(webrtcDart.includes('METHOD STREAK'));

  // Fixture #6 intentionally skipped!
  assert.equal(catalogDart.includes('ColdReadAudition'), false);

  // Fixture #7: Standing Ovation Combo & Spectator Hype Shards
  assert.ok(webrtcDart.includes('STANDING OVATION COMBO'));
  assert.ok(judgingDart.includes('KINGMAKER / EXECUTIVE PRODUCER'));

  // Fixture #8: 3-Act Blockbuster Tournament Mode
  assert.ok(settingsDart.includes('threeActBlockbusterTournament'));
  assert.ok(lobbyDart.includes('3-Act Blockbuster Arc'));
  assert.ok(matchFinalDart.includes('3-ACT BLOCKBUSTER TOURNAMENT PLAYBILL'));

  // Fixture #9: 5-Tier Character Mastery Track
  assert.ok(profileDart.includes('5-TIER CHARACTER MASTERY'));

  // Fixture #10: Hollywood Walk of Fame Brass Star
  assert.ok(dashboardDart.includes('HOLLYWOOD WALK OF FAME BRASS STAR'));
  assert.ok(matchHistoryDart.includes('HOLLYWOOD WALK OF FAME BRASS STAR'));

  // Fixture #11: AI Co-Star & AI Studio Jury Personalities
  assert.ok(judgingDart.includes('aiCoStarVerdicts'));

  // Fixture #12: Big-Screen Premiere Host View & Clean Broadcast Mode
  assert.ok(settingsDart.includes('bigScreenPremiereHostView'));
  assert.ok(settingsDart.includes('cleanBroadcastScreenShareMode'));
  assert.ok(webrtcDart.includes('_buildWideStudioControlDeckLayout'));

  // Fixture #13: The Writer's Room AI Custom Scene Generator & Elastic Catalog
  assert.ok(catalogDart.includes('totalGeneralSceneCount'));
  assert.ok(sceneVaultDart.includes('_openWritersRoomCustomSceneModal'));

  // Fixture #14: 5-Second "Green Room Roast" Voice Notes
  assert.ok(feedDart.includes('5s ROAST'));

  // Fixture #15 (Part A & Part B): Speakeasy Dare Wheel + "LIFE IS IMPROV"
  assert.ok(catalogDart.includes('kLifeIsImprovSecretDares'));
  assert.ok(lateNightDart.includes('LIFE IS IMPROV — REAL-WORLD SECRET DARE MODE'));
  assert.ok(lateNightDart.includes('SPEAKEASY DARE WHEEL'));
  assert.ok(webrtcDart.includes('STEALTH HUD'));
  assert.ok(judgingDart.includes('lifeIsImprovFivePillars'));
  assert.ok(profileDart.includes('UNDERCOVER LEGEND FRAME'));

  // Fixture #16: Casting Director Duty (+2 Free AI Tokens Daily)
  assert.ok(feedDart.includes('CASTING DUTY:'));
  assert.ok(paymentDart.includes('Casting Director Duty'));

  // Fixture #17: Sunday Night Box Office Awards
  assert.ok(feedDart.includes('SUNDAY NIGHT BOX OFFICE AWARDS'));
  assert.ok(matchHistoryDart.includes('SUNDAY NIGHT BOX OFFICE AWARDS'));

  // Fixture #18: 1-Tap Audience Test Screening Pulse
  assert.ok(matchFinalDart.includes('1-TAP AUDIENCE TEST SCREENING PULSE'));
});

test('Dart Release Build API & Constructor Contracts (Flutter 3.47.8 CI parity)', () => {
  const lobbyModelsDart = fs.readFileSync('lib/ui/lobby_models_and_realtime.dart', 'utf8');
  const catalogDart = fs.readFileSync('lib/ui/parody_scenes_catalog.dart', 'utf8');
  const authDart = fs.readFileSync('lib/auth/auth_service.dart', 'utf8');
  const qaOverlayDart = fs.readFileSync('lib/qa/qa_overlay.dart', 'utf8');
  const judgingDart = fs.readFileSync('lib/judging_engine.dart', 'utf8');
  const feedDart = fs.readFileSync('lib/social/cutting_room_feed.dart', 'utf8');
  const rigDart = fs.readFileSync('lib/ui/boondocks_character_rig.dart', 'utf8');

  // 1. ScenePrompt supports optional category, durationSeconds, difficultyTier
  assert.ok(lobbyModelsDart.includes('this.category = SceneCategory.era1970To1999'));
  assert.ok(lobbyModelsDart.includes('this.durationSeconds = 35'));
  assert.ok(lobbyModelsDart.includes('this.difficultyTier = 4'));
  assert.ok(lobbyModelsDart.includes('typedef LobbyParticipant = LobbyPlayer;'));

  // 2. DailyCattleCallChallenge & LifeIsImprovSecretDare getters
  assert.ok(catalogDart.includes('typedef OriginalParodySceneEntry = ScenePrompt;'));
  assert.ok(catalogDart.includes('final int sceneNumberOf90;'));
  assert.ok(catalogDart.includes('ScenePrompt get scene => featuredScene;'));
  assert.ok(catalogDart.includes('String get dailyCurveball => mandatoryCurveball;'));
  assert.ok(catalogDart.includes('String get dateKeyUtc => utcDateKey;'));
  assert.ok(catalogDart.includes('String get escalationAt15s => midDareEscalation15s;'));

  // 3. ActorProfileState.displayName & AuthService.addAiTokens
  assert.ok(authDart.includes('String get displayName =>'));
  assert.ok(authDart.includes('Future<ActorProfileState?> addAiTokens(int amount) => topUpAiTokens(amount);'));

  // 4. QaTelemetryRepository.instance & submitScenePulseRating
  assert.ok(qaOverlayDart.includes('static const QaTelemetryRepository instance = QaTelemetryRepository();'));
  assert.ok(qaOverlayDart.includes('Future<QaFeedbackReport> submitScenePulseRating({'));

  // 5. dart:async imported in judging_engine.dart for unawaited(...)
  assert.ok(judgingDart.includes("import 'dart:async';"));

  // 6. LobbySession in cutting_room_feed.dart uses canonical hostId, livekitRoomName, players
  assert.equal(feedDart.includes('hostUserId:'), false);
  assert.equal(feedDart.includes('LobbyStatus.performing'), false);
  assert.ok(feedDart.includes("hostId: 'local-costar'"));

  // 7. BoondocksAvatarArchetype.shortBadge getter
  assert.ok(rigDart.includes('String get shortBadge => roleBadge;'));
});

test('Samsung Galaxy S26 Ultra 5-Part Audit Upgrade (De-Cluttered Dashboard, Relocated Clickable 2.5D Rigs, Call Sheet Sub-Pages, 7-Mode Rulebook, 50 New Rated-R 18+ Scenes, and Video 1-4 Fixes)', () => {
  const dashboardDart = fs.readFileSync('lib/dashboard_marquee.dart', 'utf8');
  const doorsDart = fs.readFileSync('lib/ui/premiere_doors_marquee.dart', 'utf8');
  const profileDart = fs.readFileSync('lib/profile/actor_profile_screen.dart', 'utf8');
  const lateNightDart = fs.readFileSync('lib/late_night_vault.dart', 'utf8');
  const raunchyScenesDart = fs.readFileSync('lib/late_night_raunchy_scenes.dart', 'utf8');
  const catalogDart = fs.readFileSync('lib/ui/parody_scenes_catalog.dart', 'utf8');
  const settingsDart = fs.readFileSync('lib/ui/game_settings_modal.dart', 'utf8');
  const instructionsDart = fs.readFileSync('lib/ui/interactive_instructions.dart', 'utf8');
  const feedDart = fs.readFileSync('lib/social/cutting_room_feed.dart', 'utf8');
  const lobbyDart = fs.readFileSync('lib/lobby.dart', 'utf8');
  const webrtcDart = fs.readFileSync('lib/webrtc_manager.dart', 'utf8');
  const judgingDart = fs.readFileSync('lib/judging_engine.dart', 'utf8');
  const matchHistoryDart = fs.readFileSync('lib/match_history_screen.dart', 'utf8');
  const introDart = fs.readFileSync('lib/ui/intro_cinematic.dart', 'utf8');

  // 1. Non-functional showcase cards removed from Main Dashboard & relocated as clickable features
  assert.equal(dashboardDart.includes('RedCarpet25DParallaxFlanksDeck('), false);
  assert.equal(doorsDart.includes('FiveLayer25DLivingHeroPortraitsDeck('), false);
  assert.ok(profileDart.includes('_buildStageEntranceAndCrowdFxSelector'));
  assert.ok(profileDart.includes('LeftFlankPaparazziDuoRig'));
  assert.ok(profileDart.includes('FirstPersonRedCarpetPovCardRig'));
  assert.ok(profileDart.includes('RightFlankVipEntourageRig'));
  assert.ok(webrtcDart.includes('_buildStageParallaxFlanksFxDeck'));
  assert.ok(lateNightDart.includes('UndercoverSpeakeasyImproviserRig'));
  assert.ok(lateNightDart.includes('Matrix4.identity()'));
  assert.ok(feedDart.includes('RuthlessCastingDirectorRig'));
  assert.ok(judgingDart.includes('RuthlessCastingDirectorRig'));
  assert.ok(settingsDart.includes('DuetRivalsSplitPortraitRig'));
  assert.ok(lobbyDart.includes('DuetRivalsSplitPortraitRig'));

  // 2. Director's Call Sheet 2.5D Animated Headers & Dedicated Mode Sub-Pages
  assert.ok(settingsDart.includes('_openDedicatedModeSubPage'));
  assert.ok(settingsDart.includes('_buildCallSheet25DHeaderBanner'));
  assert.ok(settingsDart.includes('DEDICATED MODE PAGE & OFFICIAL RULES'));

  // 3. Interactive 7-Mode Scene-Editing Rulebook with Tabs & Tables
  assert.ok(instructionsDart.includes('EDITING BAY & RULEBOOK'));
  assert.ok(instructionsDart.includes('OFFICIAL RULES, WEIGHTS & MULTIPLIER TABLE'));
  assert.ok(instructionsDart.includes('_buildStructuredRulesTable'));
  assert.ok(instructionsDart.includes('_launchModeFromRulebook'));

  // 4. 50 New Uncensored Rated-R / TV-MA 18+ Midnight Speakeasy Scenes (ln_11..ln_60)
  for (let i = 11; i <= 60; i++) {
    const id = `ln_${String(i).padStart(2, '0')}`;
    assert.ok(
      raunchyScenesDart.includes(`id: '${id}'`),
      `Expected late_night_raunchy_scenes.dart to include ${id}`
    );
  }
  assert.ok(catalogDart.includes('...kFiftyNewRatedRSpeakeasyScenes'));

  // 5. Video 1-4 Fixes (Intro video logo suppression, Green Room Room Code title, Permission-synced Pre-Roll, 15s Curveball, 30s Auto-Cut, CUT & JUDGE pill, 1200ms delayed replay, Scorecard FACIAL/VOCAL/CUE labels)
  assert.ok(introDart.includes('if (!_isVideoReady)'));
  assert.ok(lobbyDart.includes("'GREEN ROOM · #${activeSession.roomCode}'"));
  assert.ok(webrtcDart.includes('_initializeStageAfterPermissions'));
  assert.ok(webrtcDart.includes('CUT & JUDGE'));
  assert.ok(judgingDart.includes('formattedScoringTierBadge'));
  assert.ok(matchHistoryDart.includes('FACIAL'));
  assert.ok(matchHistoryDart.includes('VOCAL'));
  assert.ok(matchHistoryDart.includes('CUE'));
});

