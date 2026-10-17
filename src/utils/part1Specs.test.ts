import test from 'node:test';
import assert from 'node:assert/strict';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  validateFlutterPubspec,
  validatePart2Schema,
  validatePart3WebRtcManager,
  validatePart4JudgingEngine,
  verifyLateNightAgeGate,
  getBatchCompletionRatio,
} from './part1Specs.ts';

test('All 5 parts exist in WORKSPACE_FILES and pass structural validation', () => {
  const pubspec = WORKSPACE_FILES.find((f) => f.path === 'pubspec.yaml');
  const schema = WORKSPACE_FILES.find((f) => f.path === 'supabase/schema.sql');
  const webrtc = WORKSPACE_FILES.find((f) => f.path === 'lib/webrtc_manager.dart');
  const judging = WORKSPACE_FILES.find((f) => f.path === 'lib/judging_engine.dart');
  const lateNightSql = WORKSPACE_FILES.find(
    (f) => f.path === 'supabase/late_night_schema.sql'
  );
  const lateNightDart = WORKSPACE_FILES.find(
    (f) => f.path === 'lib/late_night_vault.dart'
  );

  assert.ok(pubspec && validateFlutterPubspec(pubspec.content).valid);
  assert.ok(schema && validatePart2Schema(schema.content).valid);
  assert.ok(webrtc && validatePart3WebRtcManager(webrtc.content).valid);
  assert.ok(judging && validatePart4JudgingEngine(judging.content).valid);
  assert.ok(
    lateNightSql &&
      lateNightSql.content.includes('public.scenes_late_night_after_hours') &&
      lateNightSql.content.includes('profiles.age_verified = true')
  );
  assert.ok(
    lateNightDart &&
      lateNightDart.content.includes('verify_player_age_and_unlock_late_night')
  );
});

test('Late-Night 18+ age gate rejects underage birth years and invalid PINs', () => {
  const underage = verifyLateNightAgeGate({
    birthYear: 2012,
    currentYear: 2026,
    pinCode: '2026',
  });
  assert.equal(underage.unlocked, false);

  const badPin = verifyLateNightAgeGate({
    birthYear: 1997,
    currentYear: 2026,
    pinCode: '12',
  });
  assert.equal(badPin.unlocked, false);

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
