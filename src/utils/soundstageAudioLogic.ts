export type SoundstageZoneId =
  | 'premiere_entrance'
  | 'casting_signup_set'
  | 'red_carpet_dashboard'
  | 'star_dressing_room'
  | 'after_hours_vault';

export type SoundstageSfxId =
  | 'clapper_snap'
  | 'paparazzi_shutter_flash'
  | 'film_reel_click'
  | 'call_sheet_stamp'
  | 'dressing_room_vanity'
  | 'soundstage_door_thud'
  | 'oscar_trophy_chime'
  | 'velvet_rope_hook';

export type AudioChannelKey =
  | 'masterEnabled'
  | 'musicEnabled'
  | 'paparazziAmbienceEnabled'
  | 'interactiveSfxEnabled';

export interface SoundstageAudioSettings {
  masterEnabled: boolean;
  musicEnabled: boolean;
  paparazziAmbienceEnabled: boolean;
  interactiveSfxEnabled: boolean;
  masterVolume: number; // 0.0 to 1.0
}

export interface SoundstageZoneSpec {
  id: SoundstageZoneId;
  title: string;
  subtitle: string;
  bpm: number;
  musicalKey: string;
  ambienceSummary: string;
  chordProgressionHz: number[][];
  basslineHz: number[];
  leadMotifHz: number[];
  hasPaparazziFlashes: boolean;
}

export interface SoundstageSfxSpec {
  id: SoundstageSfxId;
  label: string;
  themeContext: string;
  durationMs: number;
}

export const DEFAULT_SOUNDSTAGE_AUDIO_SETTINGS: SoundstageAudioSettings = {
  masterEnabled: true,
  musicEnabled: true,
  paparazziAmbienceEnabled: true,
  interactiveSfxEnabled: true,
  masterVolume: 0.75,
};

export const SOUNDSTAGE_ZONES: Record<SoundstageZoneId, SoundstageZoneSpec> = {
  premiere_entrance: {
    id: 'premiere_entrance',
    title: 'Premiere Grand Entrance Overture',
    subtitle: 'State-of-the-art Klieg searchlight brass swell, red carpet arrival fanfare & clapperboard ignition',
    bpm: 118,
    musicalKey: 'C Major 9 (Heroic Fanfare)',
    ambienceSummary: 'Searchlight carbon-arc hum, velvet rope crowd swell & wooden slate snap',
    chordProgressionHz: [
      [261.63, 329.63, 392.0, 493.88, 587.33], // Cmaj9
      [293.66, 369.99, 440.0, 523.25, 659.25], // D13/C
      [349.23, 440.0, 523.25, 659.25, 783.99],  // Fmaj9
      [392.0, 493.88, 587.33, 698.46, 880.0],   // G13
    ],
    basslineHz: [130.81, 146.83, 174.61, 196.0],
    leadMotifHz: [523.25, 659.25, 783.99, 1046.5, 987.77, 783.99, 659.25, 783.99],
    hasPaparazziFlashes: true,
  },
  casting_signup_set: {
    id: 'casting_signup_set',
    title: 'On-Set Casting Call & Sign-In Groove',
    subtitle: 'Live Hollywood soundstage check-in pulse, script page rustle, call-sheet stamp & stage relay clicks',
    bpm: 112,
    musicalKey: 'E Dorian (Backstage Set Groove)',
    ambienceSummary: 'Director chair canvas creak, call-sheet clipboard clamp, stage dimmer click & warm Rhodes pulse',
    chordProgressionHz: [
      [329.63, 392.0, 493.88, 587.33], // Em7
      [220.0, 277.18, 329.63, 440.0],  // A9
      [293.66, 369.99, 440.0, 523.25], // Dmaj7
      [246.94, 311.13, 369.99, 493.88], // B7sus4
    ],
    basslineHz: [82.41, 110.0, 146.83, 123.47],
    leadMotifHz: [659.25, 587.33, 493.88, 587.33, 659.25, 739.99, 659.25, 493.88],
    hasPaparazziFlashes: false,
  },
  red_carpet_dashboard: {
    id: 'red_carpet_dashboard',
    title: 'Red Carpet Inspiring Anthem & Paparazzi Frenzy',
    subtitle: 'Uplifting, motivating premiere main-stage anthem layered with live paparazzi DSLR shutters & flashbulbs',
    bpm: 124,
    musicalKey: 'A Major / F#m9 (Motivating Superstar Anthem)',
    ambienceSummary: 'Rapid paparazzi DSLR shutter bursts, vintage flashbulb pops, capacitor recharge whines & press cheers',
    chordProgressionHz: [
      [220.0, 277.18, 329.63, 415.3, 493.88],  // Amaj9
      [185.0, 220.0, 277.18, 329.63, 415.3],   // F#m9
      [293.66, 369.99, 440.0, 554.37, 659.25], // Dmaj9
      [329.63, 415.3, 493.88, 587.33, 739.99], // E13
    ],
    basslineHz: [110.0, 92.5, 146.83, 164.81],
    leadMotifHz: [440.0, 554.37, 659.25, 880.0, 830.61, 659.25, 739.99, 880.0],
    hasPaparazziFlashes: true,
  },
  star_dressing_room: {
    id: 'star_dressing_room',
    title: 'Star Dressing Room & Vanity Mirror Lounge',
    subtitle: 'Warm neo-soul green-room Rhodes, incandescent vanity mirror bulb pings, wardrobe rack & vocal warm-up chimes',
    bpm: 96,
    musicalKey: 'F Major 9 (Velvet Green-Room Neo-Soul)',
    ambienceSummary: 'Incandescent vanity bulb warm-up ticks, silk wardrobe zipper & crystal atomizer mist',
    chordProgressionHz: [
      [174.61, 220.0, 261.63, 329.63, 392.0],  // Fmaj9
      [164.81, 196.0, 246.94, 293.66, 349.23], // Em7b5/A7
      [146.83, 174.61, 220.0, 261.63, 329.63], // Dm9
      [196.0, 233.08, 293.66, 349.23, 440.0],  // Gm9/C13
    ],
    basslineHz: [87.31, 82.41, 73.42, 98.0],
    leadMotifHz: [523.25, 440.0, 392.0, 349.23, 440.0, 523.25, 587.33, 523.25],
    hasPaparazziFlashes: false,
  },
  after_hours_vault: {
    id: 'after_hours_vault',
    title: 'Late-Night 18+ After-Hours Velvet Noir',
    subtitle: 'Midnight speakeasy Rhodes, upright bass pulse, heavy steel vault tumblers & neon transformer hum',
    bpm: 88,
    musicalKey: 'C Minor 11 (Midnight Studio Noir)',
    ambienceSummary: 'Heavy steel vault lock tumblers, smoky upright bass & vintage neon tube buzz',
    chordProgressionHz: [
      [261.63, 311.13, 392.0, 466.16, 587.33], // Cm11
      [207.65, 261.63, 311.13, 392.0, 466.16], // Abmaj9
      [174.61, 207.65, 261.63, 311.13, 392.0], // Fm9
      [196.0, 246.94, 293.66, 349.23, 415.3],  // G7alt
    ],
    basslineHz: [65.41, 103.83, 87.31, 98.0],
    leadMotifHz: [523.25, 466.16, 392.0, 311.13, 349.23, 392.0, 311.13, 261.63],
    hasPaparazziFlashes: false,
  },
};

export const SOUNDSTAGE_SFX_SPECS: Record<SoundstageSfxId, SoundstageSfxSpec> = {
  clapper_snap: {
    id: 'clapper_snap',
    label: 'Hollywood Clapperboard Snap',
    themeContext: 'Scene Action / Form Submit / Sign-Up Confirmation',
    durationMs: 380,
  },
  paparazzi_shutter_flash: {
    id: 'paparazzi_shutter_flash',
    label: 'Paparazzi DSLR Burst & Flashbulb Pop',
    themeContext: 'Red Carpet Camera Flash / Press Photo / Spotlight Trigger',
    durationMs: 680,
  },
  film_reel_click: {
    id: 'film_reel_click',
    label: '35mm Projector Reel Sprocket Click',
    themeContext: 'Navigation Tab Switch / Mode Selector / Filter Toggle',
    durationMs: 190,
  },
  call_sheet_stamp: {
    id: 'call_sheet_stamp',
    label: 'Casting Director Call-Sheet Seal Stamp',
    themeContext: 'NDA Signature / Tester Passcode Issue / Dossier Lock',
    durationMs: 420,
  },
  dressing_room_vanity: {
    id: 'dressing_room_vanity',
    label: 'Vanity Mirror Bulb Ping & Velvet Rack Slide',
    themeContext: 'Dressing Room Archetype Select / Wardrobe / Actor Profile',
    durationMs: 520,
  },
  soundstage_door_thud: {
    id: 'soundstage_door_thud',
    label: 'Heavy Soundstage Airlock Door Seal',
    themeContext: 'Entering Stage Door / Room Code Lock / Security Gate',
    durationMs: 620,
  },
  oscar_trophy_chime: {
    id: 'oscar_trophy_chime',
    label: 'Golden Academy Envelope & Trophy Fanfare',
    themeContext: 'Tester Approved / Gate Unlocked / Award Verdict',
    durationMs: 920,
  },
  velvet_rope_hook: {
    id: 'velvet_rope_hook',
    label: 'Brass Stanchion Velvet Rope Unhook',
    themeContext: 'Audio Switch Toggle / VIP Access Control',
    durationMs: 240,
  },
};

export function shouldPlayChannel(
  settings: SoundstageAudioSettings,
  channel: Exclude<AudioChannelKey, 'masterEnabled'>
): boolean {
  if (!settings.masterEnabled) return false;
  if (settings.masterVolume <= 0) return false;
  return Boolean(settings[channel]);
}

export function toggleAudioChannel(
  settings: SoundstageAudioSettings,
  channel: AudioChannelKey
): SoundstageAudioSettings {
  return {
    ...settings,
    [channel]: !settings[channel],
  };
}

export function setMasterVolumeLevel(
  settings: SoundstageAudioSettings,
  volume: number
): SoundstageAudioSettings {
  const clamped = Math.max(0, Math.min(1, Number.isFinite(volume) ? volume : 0.75));
  return {
    ...settings,
    masterVolume: clamped,
    masterEnabled: clamped > 0 ? settings.masterEnabled : false,
  };
}

export function resolveZoneForScreen(params: {
  ndaUnlocked: boolean;
  ndaMode: 'sign' | 'unlock' | 'admin';
  activeTab: string;
}): SoundstageZoneId {
  if (!params.ndaUnlocked) {
    if (params.ndaMode === 'sign') {
      return 'casting_signup_set';
    }
    if (params.ndaMode === 'unlock') {
      return 'premiere_entrance';
    }
    return 'casting_signup_set';
  }
  switch (params.activeTab) {
    case 'dressing-room':
      return 'star_dressing_room';
    case 'late-night':
      return 'after_hours_vault';
    case 'red-carpet':
    case 'files':
    case 'sync-guide':
    default:
      return 'red_carpet_dashboard';
  }
}

export function getSfxForInteraction(interactionType: string): SoundstageSfxId {
  switch (interactionType) {
    case 'submit_signup':
    case 'action_slate':
      return 'clapper_snap';
    case 'paparazzi_flash':
    case 'red_carpet_photo':
      return 'paparazzi_shutter_flash';
    case 'tab_switch':
    case 'filter_select':
      return 'film_reel_click';
    case 'nda_stamp':
    case 'copy_code':
      return 'call_sheet_stamp';
    case 'dressing_room':
    case 'archetype_pick':
      return 'dressing_room_vanity';
    case 'stage_door':
    case 'vault_lock':
      return 'soundstage_door_thud';
    case 'unlock_success':
    case 'approve_tester':
      return 'oscar_trophy_chime';
    case 'audio_toggle':
    default:
      return 'velvet_rope_hook';
  }
}
