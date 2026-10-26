import test from 'node:test';
import assert from 'node:assert/strict';
import {
  DEFAULT_SOUNDSTAGE_AUDIO_SETTINGS,
  SOUNDSTAGE_SFX_SPECS,
  SOUNDSTAGE_ZONES,
  getSfxForInteraction,
  resolveZoneForScreen,
  setMasterVolumeLevel,
  shouldPlayChannel,
  toggleAudioChannel,
} from './soundstageAudioLogic';

test('SOUNDSTAGE_ZONES defines all 5 distinct theme zones with musical progressions', () => {
  const zoneIds = Object.keys(SOUNDSTAGE_ZONES);
  assert.deepEqual(zoneIds, [
    'premiere_entrance',
    'casting_signup_set',
    'red_carpet_dashboard',
    'star_dressing_room',
    'after_hours_vault',
  ]);

  assert.equal(SOUNDSTAGE_ZONES.red_carpet_dashboard.hasPaparazziFlashes, true);
  assert.equal(SOUNDSTAGE_ZONES.premiere_entrance.hasPaparazziFlashes, true);
  assert.equal(SOUNDSTAGE_ZONES.star_dressing_room.hasPaparazziFlashes, false);
  for (const zone of Object.values(SOUNDSTAGE_ZONES)) {
    assert.ok(zone.chordProgressionHz.length >= 4);
    assert.ok(zone.leadMotifHz.length >= 8);
    assert.ok(zone.bpm >= 80 && zone.bpm <= 140);
  }
});

test('shouldPlayChannel respects masterEnabled and individual channel toggles', () => {
  const base = { ...DEFAULT_SOUNDSTAGE_AUDIO_SETTINGS };
  assert.equal(shouldPlayChannel(base, 'musicEnabled'), true);
  assert.equal(shouldPlayChannel(base, 'paparazziAmbienceEnabled'), true);
  assert.equal(shouldPlayChannel(base, 'interactiveSfxEnabled'), true);

  const musicMuted = toggleAudioChannel(base, 'musicEnabled');
  assert.equal(shouldPlayChannel(musicMuted, 'musicEnabled'), false);
  assert.equal(shouldPlayChannel(musicMuted, 'paparazziAmbienceEnabled'), true);

  const masterMuted = toggleAudioChannel(base, 'masterEnabled');
  assert.equal(shouldPlayChannel(masterMuted, 'musicEnabled'), false);
  assert.equal(shouldPlayChannel(masterMuted, 'paparazziAmbienceEnabled'), false);
  assert.equal(shouldPlayChannel(masterMuted, 'interactiveSfxEnabled'), false);

  const zeroVol = setMasterVolumeLevel(base, 0);
  assert.equal(shouldPlayChannel(zeroVol, 'musicEnabled'), false);
});

test('resolveZoneForScreen maps sign-up, entrance, dressing room, dashboard, and vault accurately', () => {
  assert.equal(
    resolveZoneForScreen({ ndaUnlocked: false, ndaMode: 'sign', activeTab: 'files' }),
    'casting_signup_set'
  );
  assert.equal(
    resolveZoneForScreen({ ndaUnlocked: false, ndaMode: 'unlock', activeTab: 'files' }),
    'premiere_entrance'
  );
  assert.equal(
    resolveZoneForScreen({ ndaUnlocked: true, ndaMode: 'sign', activeTab: 'red-carpet' }),
    'red_carpet_dashboard'
  );
  assert.equal(
    resolveZoneForScreen({ ndaUnlocked: true, ndaMode: 'sign', activeTab: 'dressing-room' }),
    'star_dressing_room'
  );
  assert.equal(
    resolveZoneForScreen({ ndaUnlocked: true, ndaMode: 'sign', activeTab: 'late-night' }),
    'after_hours_vault'
  );
});

test('getSfxForInteraction returns distinct theme-specific sound effect IDs', () => {
  assert.equal(getSfxForInteraction('submit_signup'), 'clapper_snap');
  assert.equal(getSfxForInteraction('paparazzi_flash'), 'paparazzi_shutter_flash');
  assert.equal(getSfxForInteraction('tab_switch'), 'film_reel_click');
  assert.equal(getSfxForInteraction('dressing_room'), 'dressing_room_vanity');
  assert.equal(getSfxForInteraction('unlock_success'), 'oscar_trophy_chime');
  assert.ok(SOUNDSTAGE_SFX_SPECS[getSfxForInteraction('paparazzi_flash')].durationMs > 500);
});
