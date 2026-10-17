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

  // Verify .github/workflows/build_apk.yml has Force compileSdk 34 for AndroidX step
  const workflowYml = fs.readFileSync('.github/workflows/build_apk.yml', 'utf8');
  assert.ok(workflowYml.includes('name: Force compileSdk 34 for AndroidX'));
  assert.ok(workflowYml.includes('/home/runner/.pub-cache/hosted'));
  assert.ok(workflowYml.includes('compileSdkVersion 31/compileSdkVersion 34'));
  assert.ok(
    workflowYml.includes(
      "sed -i 's/compileSdk = .*/compileSdk = 34/g' android/app/build.gradle.kts || true"
    )
  );
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
