import React from 'react';
import {
  Volume2,
  VolumeX,
  Music,
  Camera,
  Sparkles,
  Clapperboard,
  Film,
  Stamp,
  Award,
  DoorClosed,
} from 'lucide-react';
import {
  AudioChannelKey,
  SOUNDSTAGE_SFX_SPECS,
  SOUNDSTAGE_ZONES,
  SoundstageAudioSettings,
  SoundstageSfxId,
  SoundstageZoneId,
} from '../utils/soundstageAudioLogic';

interface SoundstageAudioConsoleProps {
  activeZone: SoundstageZoneId;
  settings: SoundstageAudioSettings;
  paparazziFlashActive: boolean;
  lastTriggeredSfx: SoundstageSfxId | null;
  onToggleChannel: (channel: AudioChannelKey) => void;
  onVolumeChange: (volume: number) => void;
  onSelectZone: (zone: SoundstageZoneId) => void;
  onTriggerSfx: (sfx: SoundstageSfxId) => void;
  contextLabel?: string;
}

export const SoundstageAudioConsole: React.FC<SoundstageAudioConsoleProps> = ({
  activeZone,
  settings,
  paparazziFlashActive,
  lastTriggeredSfx,
  onToggleChannel,
  onVolumeChange,
  onSelectZone,
  onTriggerSfx,
  contextLabel = 'SOUNDSTAGE AUDIO & PAPARAZZI CONSOLE',
}) => {
  const zoneSpec = SOUNDSTAGE_ZONES[activeZone];
  const masterOn = settings.masterEnabled && settings.masterVolume > 0;
  const musicOn = masterOn && settings.musicEnabled;
  const paparazziOn = masterOn && settings.paparazziAmbienceEnabled;
  const sfxOn = masterOn && settings.interactiveSfxEnabled;

  return (
    <section
      aria-label={contextLabel}
      className={`rounded-xl border transition-all p-4 space-y-3.5 ${
        paparazziFlashActive
          ? 'bg-amber-950/60 border-amber-300 shadow-[0_0_25px_rgba(251,191,36,0.35)]'
          : masterOn
          ? 'bg-slate-950/95 border-amber-500/60'
          : 'bg-slate-950/90 border-slate-800'
      }`}
    >
      {/* Top Row: Active Zone Title, BPM/Key & Paparazzi Flash Button */}
      <div className="flex flex-col xl:flex-row xl:items-center justify-between gap-3">
        <div className="flex items-start gap-3 min-w-0">
          <div
            className={`p-2.5 rounded-lg border shrink-0 ${
              masterOn
                ? 'bg-amber-500/15 border-amber-400 text-amber-300'
                : 'bg-slate-900 border-slate-700 text-slate-500'
            }`}
          >
            {masterOn ? (
              <Volume2 className="w-5 h-5" />
            ) : (
              <VolumeX className="w-5 h-5" />
            )}
          </div>
          <div className="space-y-0.5 min-w-0">
            <div className="text-xs text-amber-300 font-mono font-bold">
              <span>{contextLabel}</span>
              <span aria-hidden="true" className="mx-1.5 text-slate-500">
                ·
              </span>
              <span className="text-cyan-300">
                {zoneSpec.musicalKey} ({zoneSpec.bpm} BPM)
              </span>
            </div>
            <h2 className="text-sm sm:text-base font-bold text-white">
              {zoneSpec.title}
            </h2>
            <p className="text-xs text-slate-300 leading-relaxed">
              {zoneSpec.subtitle}
            </p>
          </div>
        </div>

        {/* Live Paparazzi Camera Shutter & Flash Trigger + Volume Slider */}
        <div className="flex flex-wrap items-center gap-3 shrink-0">
          <button
            type="button"
            onClick={() => onTriggerSfx('paparazzi_shutter_flash')}
            className="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-400 text-cyan-200 text-xs font-mono font-bold transition-colors"
          >
            <Camera className="w-3.5 h-3.5 text-cyan-300" />
            <span>Trigger Paparazzi Flash &amp; Shutter</span>
          </button>

          <div className="flex items-center gap-2 bg-slate-900 border border-slate-800 rounded-lg px-3 py-1.5">
            <label
              htmlFor={`soundstage-volume-${contextLabel.replace(/\s+/g, '-').toLowerCase()}`}
              className="text-xs font-mono text-slate-300 whitespace-nowrap"
            >
              Vol: {Math.round(settings.masterVolume * 100)}%
            </label>
            <input
              id={`soundstage-volume-${contextLabel.replace(/\s+/g, '-').toLowerCase()}`}
              type="range"
              min={0}
              max={100}
              value={Math.round(settings.masterVolume * 100)}
              onChange={(e) => onVolumeChange(Number(e.target.value) / 100)}
              className="w-20 accent-amber-400 cursor-pointer"
            />
          </div>
        </div>
      </div>

      {/* Row 2: 4 Individual On/Off Toggles for Every Part of the Sound & Music */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-2">
        <button
          type="button"
          aria-pressed={masterOn}
          onClick={() => onToggleChannel('masterEnabled')}
          className={`flex items-center justify-between px-3 py-2 rounded-lg border text-xs font-mono font-bold transition-colors ${
            masterOn
              ? 'bg-emerald-950/70 border-emerald-400 text-emerald-200'
              : 'bg-slate-900 border-slate-800 text-slate-400'
          }`}
        >
          <span className="flex items-center gap-1.5">
            {masterOn ? (
              <Volume2 className="w-3.5 h-3.5 text-emerald-400" />
            ) : (
              <VolumeX className="w-3.5 h-3.5 text-slate-500" />
            )}
            <span>Master Audio</span>
          </span>
          <span>{masterOn ? 'ON' : 'OFF'}</span>
        </button>

        <button
          type="button"
          aria-pressed={musicOn}
          onClick={() => onToggleChannel('musicEnabled')}
          className={`flex items-center justify-between px-3 py-2 rounded-lg border text-xs font-mono font-bold transition-colors ${
            musicOn
              ? 'bg-amber-950/70 border-amber-400 text-amber-200'
              : 'bg-slate-900 border-slate-800 text-slate-400'
          }`}
        >
          <span className="flex items-center gap-1.5">
            <Music className="w-3.5 h-3.5 text-amber-400" />
            <span>Theme Music</span>
          </span>
          <span>{musicOn ? 'ON' : 'OFF'}</span>
        </button>

        <button
          type="button"
          aria-pressed={paparazziOn}
          onClick={() => onToggleChannel('paparazziAmbienceEnabled')}
          className={`flex items-center justify-between px-3 py-2 rounded-lg border text-xs font-mono font-bold transition-colors ${
            paparazziOn
              ? 'bg-cyan-950/70 border-cyan-400 text-cyan-200'
              : 'bg-slate-900 border-slate-800 text-slate-400'
          }`}
        >
          <span className="flex items-center gap-1.5">
            <Camera className="w-3.5 h-3.5 text-cyan-400" />
            <span>Paparazzi &amp; Set Ambience</span>
          </span>
          <span>{paparazziOn ? 'ON' : 'OFF'}</span>
        </button>

        <button
          type="button"
          aria-pressed={sfxOn}
          onClick={() => onToggleChannel('interactiveSfxEnabled')}
          className={`flex items-center justify-between px-3 py-2 rounded-lg border text-xs font-mono font-bold transition-colors ${
            sfxOn
              ? 'bg-purple-950/70 border-purple-400 text-purple-200'
              : 'bg-slate-900 border-slate-800 text-slate-400'
          }`}
        >
          <span className="flex items-center gap-1.5">
            <Clapperboard className="w-3.5 h-3.5 text-purple-400" />
            <span>Prop Click SFX</span>
          </span>
          <span>{sfxOn ? 'ON' : 'OFF'}</span>
        </button>
      </div>

      {/* Row 3: Zone Selector Tabs + Bespoke Theme SFX Audition Strip */}
      <div className="pt-2 border-t border-slate-800/80 flex flex-col xl:flex-row xl:items-center justify-between gap-2.5">
        <div className="flex flex-wrap items-center gap-1.5">
          <span className="text-[11px] font-mono text-slate-400 mr-1">
            Soundstage Zone:
          </span>
          {(
            [
              ['premiere_entrance', '1. Premiere Entrance'],
              ['casting_signup_set', '2. Sign-Up Casting Set'],
              ['red_carpet_dashboard', '3. Red Carpet + Paparazzi'],
              ['star_dressing_room', '4. Star Dressing Room'],
              ['after_hours_vault', '5. After-Hours Vault'],
            ] as const
          ).map(([zoneKey, label]) => (
            <button
              key={zoneKey}
              type="button"
              onClick={() => onSelectZone(zoneKey)}
              className={`px-2.5 py-1 rounded-md text-xs font-mono font-semibold transition-colors ${
                activeZone === zoneKey
                  ? 'bg-amber-400 text-slate-950 font-bold'
                  : 'bg-slate-900 text-slate-300 border border-slate-800 hover:border-slate-700'
              }`}
            >
              {label}
            </button>
          ))}
        </div>

        <div className="flex flex-wrap items-center gap-1.5">
          <span className="text-[11px] font-mono text-slate-400 mr-1">
            Theme SFX:
          </span>
          <button
            type="button"
            onClick={() => onTriggerSfx('clapper_snap')}
            className="inline-flex items-center gap-1 px-2 py-1 rounded bg-slate-900 hover:bg-slate-800 border border-slate-700 text-[11px] font-mono text-amber-200"
          >
            <Clapperboard className="w-3 h-3 text-amber-400" />
            <span>Clapper Snap</span>
          </button>
          <button
            type="button"
            onClick={() => onTriggerSfx('dressing_room_vanity')}
            className="inline-flex items-center gap-1 px-2 py-1 rounded bg-slate-900 hover:bg-slate-800 border border-slate-700 text-[11px] font-mono text-pink-200"
          >
            <Sparkles className="w-3 h-3 text-pink-400" />
            <span>Dressing Room Vanity</span>
          </button>
          <button
            type="button"
            onClick={() => onTriggerSfx('call_sheet_stamp')}
            className="inline-flex items-center gap-1 px-2 py-1 rounded bg-slate-900 hover:bg-slate-800 border border-slate-700 text-[11px] font-mono text-emerald-200"
          >
            <Stamp className="w-3 h-3 text-emerald-400" />
            <span>Call-Sheet Stamp</span>
          </button>
          <button
            type="button"
            onClick={() => onTriggerSfx('film_reel_click')}
            className="inline-flex items-center gap-1 px-2 py-1 rounded bg-slate-900 hover:bg-slate-800 border border-slate-700 text-[11px] font-mono text-cyan-200"
          >
            <Film className="w-3 h-3 text-cyan-400" />
            <span>35mm Reel</span>
          </button>
          <button
            type="button"
            onClick={() => onTriggerSfx('soundstage_door_thud')}
            className="inline-flex items-center gap-1 px-2 py-1 rounded bg-slate-900 hover:bg-slate-800 border border-slate-700 text-[11px] font-mono text-slate-200"
          >
            <DoorClosed className="w-3 h-3 text-slate-400" />
            <span>Stage Door</span>
          </button>
          <button
            type="button"
            onClick={() => onTriggerSfx('oscar_trophy_chime')}
            className="inline-flex items-center gap-1 px-2 py-1 rounded bg-slate-900 hover:bg-slate-800 border border-slate-700 text-[11px] font-mono text-amber-300"
          >
            <Award className="w-3 h-3 text-amber-400" />
            <span>Award Fanfare</span>
          </button>
        </div>
      </div>

      {/* Live Foley & Ambience Telemetry Line */}
      <div className="flex flex-wrap items-center justify-between gap-2 text-[11px] font-mono text-slate-400">
        <span>Ambience Layer: {zoneSpec.ambienceSummary}</span>
        {lastTriggeredSfx && (
          <span className="text-amber-300">
            Last Cue: {SOUNDSTAGE_SFX_SPECS[lastTriggeredSfx].label} (
            {SOUNDSTAGE_SFX_SPECS[lastTriggeredSfx].themeContext})
          </span>
        )}
      </div>
    </section>
  );
};
