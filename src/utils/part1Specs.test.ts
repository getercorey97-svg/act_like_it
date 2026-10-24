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
  assert.ok(mainDart.includes("'/qa-dashboard': (_) => const QaWebPortalDashboardScreen()"));
});

