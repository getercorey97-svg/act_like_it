import test from 'node:test';
import assert from 'node:assert/strict';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  validateFlutterPubspec,
  validatePart2Schema,
  validatePart3WebRtcManager,
  calculateSfuBandwidthSavings,
  isSixDigitLobbyCode,
  getBatchCompletionRatio,
} from './part1Specs.ts';

test('Part 1 pubspec.yaml includes required Supabase, LiveKit, and Gemini packages', () => {
  const pubspec = WORKSPACE_FILES.find((f) => f.path === 'pubspec.yaml');
  assert.ok(pubspec, 'pubspec.yaml must exist in WORKSPACE_FILES');
  assert.equal(validateFlutterPubspec(pubspec.content).valid, true);
});

test('Part 2 supabase/schema.sql defines profiles, Eras, Awards, Cult Classics, and Realtime lobbies', () => {
  const schema = WORKSPACE_FILES.find((f) => f.path === 'supabase/schema.sql');
  assert.ok(schema, 'supabase/schema.sql must exist in WORKSPACE_FILES');
  assert.equal(validatePart2Schema(schema.content).valid, true);
});

test('Part 3 lib/webrtc_manager.dart configures adaptiveStream, dynacast, and simulcast', () => {
  const webrtc = WORKSPACE_FILES.find((f) => f.path === 'lib/webrtc_manager.dart');
  assert.ok(webrtc, 'lib/webrtc_manager.dart must exist in WORKSPACE_FILES');
  const check = validatePart3WebRtcManager(webrtc.content);
  assert.equal(check.hasAdaptiveStream, true);
  assert.equal(check.hasDynacast, true);
  assert.equal(check.hasSimulcast, true);
  assert.equal(check.valid, true);
});

test('LiveKit SFU bandwidth calculator prevents throttling across 8 remote players', () => {
  const performerMetrics = calculateSfuBandwidthSavings(8, 'activePerformer');
  assert.equal(performerMetrics.clampedPlayers, 8);
  assert.equal(performerMetrics.sfuUpstreamKbps, 1500);
  assert.equal(performerMetrics.p2pUpstreamKbps, 10500);
  assert.equal(performerMetrics.bandwidthSavedPercent, 86);

  const spectatorMetrics = calculateSfuBandwidthSavings(8, 'remoteSpectator');
  assert.equal(spectatorMetrics.sfuUpstreamKbps, 32);
  assert.ok(spectatorMetrics.bandwidthSavedPercent >= 99);
});

test('6-digit lobby code validator enforces exact 6 numeric digits', () => {
  assert.equal(isSixDigitLobbyCode('482910'), true);
  assert.equal(isSixDigitLobbyCode('12A456'), false);
});

test('Batch progress accurately reports Part 3 of 5 completed (60%)', () => {
  const progress = getBatchCompletionRatio(BATCH_STAGES);
  assert.equal(progress.completedCount, 3);
  assert.equal(progress.totalCount, 5);
  assert.equal(progress.percentage, 60);
});
