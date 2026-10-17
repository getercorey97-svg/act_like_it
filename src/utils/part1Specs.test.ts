import test from 'node:test';
import assert from 'node:assert/strict';
import {
  BATCH_STAGES,
  WORKSPACE_FILES,
  validateFlutterPubspec,
  validatePart2Schema,
  isSixDigitLobbyCode,
  getBatchCompletionRatio,
} from './part1Specs.ts';

test('Part 1 pubspec.yaml includes required Supabase, LiveKit, and Gemini packages', () => {
  const pubspec = WORKSPACE_FILES.find((f) => f.path === 'pubspec.yaml');
  assert.ok(pubspec, 'pubspec.yaml must exist in WORKSPACE_FILES');
  const validation = validateFlutterPubspec(pubspec.content);
  assert.equal(validation.valid, true);
});

test('Part 2 supabase/schema.sql defines profiles, Eras, Awards, Cult Classics, and Realtime lobbies', () => {
  const schema = WORKSPACE_FILES.find((f) => f.path === 'supabase/schema.sql');
  assert.ok(schema, 'supabase/schema.sql must exist in WORKSPACE_FILES');
  const check = validatePart2Schema(schema.content);
  assert.equal(check.hasProfiles, true);
  assert.equal(check.hasErasTables, true);
  assert.equal(check.hasAwardsTable, true);
  assert.equal(check.hasCultClassicsTable, true);
  assert.equal(check.hasLobbiesRealtime, true);
  assert.equal(check.valid, true);
});

test('6-digit lobby code validator enforces exact 6 numeric digits', () => {
  assert.equal(isSixDigitLobbyCode('482910'), true);
  assert.equal(isSixDigitLobbyCode('12345'), false);
  assert.equal(isSixDigitLobbyCode('1234567'), false);
  assert.equal(isSixDigitLobbyCode('12A456'), false);
});

test('Batch progress accurately reports Part 2 of 5 completed (40%)', () => {
  const progress = getBatchCompletionRatio(BATCH_STAGES);
  assert.equal(progress.completedCount, 2);
  assert.equal(progress.totalCount, 5);
  assert.equal(progress.percentage, 40);
});
