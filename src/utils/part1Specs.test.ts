import test from 'node:test';
import assert from 'node:assert/strict';
import {
  BATCH_STAGES,
  PART_1_FILES,
  validateFlutterPubspec,
  getBatchCompletionRatio,
} from './part1Specs.ts';

test('Part 1 pubspec.yaml includes required Supabase, LiveKit, and Gemini packages', () => {
  const pubspec = PART_1_FILES.find((f) => f.path === 'pubspec.yaml');
  assert.ok(pubspec, 'pubspec.yaml must exist in PART_1_FILES');
  const validation = validateFlutterPubspec(pubspec.content);
  assert.equal(validation.hasSupabase, true);
  assert.equal(validation.hasLiveKit, true);
  assert.equal(validation.hasGemini, true);
  assert.equal(validation.valid, true);
});

test('Batch progress accurately reports Part 1 of 5 completed (20%)', () => {
  const progress = getBatchCompletionRatio(BATCH_STAGES);
  assert.equal(progress.completedCount, 1);
  assert.equal(progress.totalCount, 5);
  assert.equal(progress.percentage, 20);
});
