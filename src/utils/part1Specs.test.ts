import test from 'node:test';
import assert from 'node:assert/strict';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  validateFlutterPubspec,
  validatePart2Schema,
  validatePart3WebRtcManager,
  validatePart4JudgingEngine,
  calculateTriModalCompositeScore,
  getBatchCompletionRatio,
} from './part1Specs.ts';

test('Part 1 pubspec.yaml includes required Supabase, LiveKit, and Gemini packages', () => {
  const pubspec = WORKSPACE_FILES.find((f) => f.path === 'pubspec.yaml');
  assert.ok(pubspec);
  assert.equal(validateFlutterPubspec(pubspec.content).valid, true);
});

test('Part 2 supabase/schema.sql defines profiles, Eras, Awards, Cult Classics, and Realtime lobbies', () => {
  const schema = WORKSPACE_FILES.find((f) => f.path === 'supabase/schema.sql');
  assert.ok(schema);
  assert.equal(validatePart2Schema(schema.content).valid, true);
});

test('Part 3 lib/webrtc_manager.dart configures adaptiveStream, dynacast, and simulcast', () => {
  const webrtc = WORKSPACE_FILES.find((f) => f.path === 'lib/webrtc_manager.dart');
  assert.ok(webrtc);
  assert.equal(validatePart3WebRtcManager(webrtc.content).valid, true);
});

test('Part 4 lib/judging_engine.dart integrates Gemini 2.5 Flash, performance-loops storage, and video setLooping(true)', () => {
  const judging = WORKSPACE_FILES.find((f) => f.path === 'lib/judging_engine.dart');
  assert.ok(judging, 'lib/judging_engine.dart must exist in WORKSPACE_FILES');
  const check = validatePart4JudgingEngine(judging.content);
  assert.equal(check.hasGeminiModel, true);
  assert.equal(check.hasSupabaseStorageLoop, true);
  assert.equal(check.hasVideoLooping, true);
  assert.equal(check.valid, true);
});

test('Tri-Modal composite score weights AI (45%), Peer (35%), and Social (20%) accurately', () => {
  const result = calculateTriModalCompositeScore({
    facialExpression: 90,
    vocalCadence: 90,
    directorCueFidelity: 90,
    peerVoteScore: 80,
    externalShares: 3,
    externalReactions: 6,
    loopCompletions: 10,
  });
  assert.equal(result.aiScore, 90);
  assert.equal(result.peerScore, 80);
  assert.ok(result.socialScore > 80);
  assert.ok(result.compositeScore > 85);
});

test('Batch progress accurately reports Part 4 of 5 completed (80%)', () => {
  const progress = getBatchCompletionRatio(BATCH_STAGES);
  assert.equal(progress.completedCount, 4);
  assert.equal(progress.totalCount, 5);
  assert.equal(progress.percentage, 80);
});
