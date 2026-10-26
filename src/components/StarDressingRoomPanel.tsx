import React, { useState } from 'react';
import {
  Camera,
  Sparkles,
  Music,
  Clapperboard,
  Award,
  Check,
} from 'lucide-react';
import { SoundstageSfxId, SoundstageZoneId } from '../utils/soundstageAudioLogic';

interface StarDressingRoomPanelProps {
  onTriggerSfx: (sfx: SoundstageSfxId) => void;
  onSelectZone: (zone: SoundstageZoneId) => void;
  activeZone: SoundstageZoneId;
}

const DRESSING_ROOM_ARCHETYPES = [
  {
    id: 'method_maestro',
    name: 'The Method Maestro',
    wardrobe: 'Velvet Tuxedo & Gold Cyber-Mask',
    eraSpecialty: '1970–1999 New Hollywood',
    vocalTone: 'Baritone Intensity · Slow Burn',
  },
  {
    id: 'scream_queen_icon',
    name: 'The Midnight Scream Icon',
    wardrobe: 'Crimson Sequined Gown & Noir Gloves',
    eraSpecialty: 'Psychological Thriller & Best Actress',
    vocalTone: 'High-Tension Whisper to Shattering Crescendo',
  },
  {
    id: 'deadpan_scene_stealer',
    name: 'The Deadpan Scene-Stealer',
    wardrobe: 'Vintage Leather Jacket & Tinted Aviators',
    eraSpecialty: 'Cult Classics & Improv Roulette',
    vocalTone: 'Razor-Sharp Timing · Zero-Blink Delivery',
  },
  {
    id: 'blockbuster_action_lead',
    name: 'The High-Voltage Action Lead',
    wardrobe: 'Tactical Premiere Suit & Stunt Chrono',
    eraSpecialty: '2000–2026 Modern Prestige',
    vocalTone: 'Commanding Projection · 124 BPM Adrenaline',
  },
];

export const StarDressingRoomPanel: React.FC<StarDressingRoomPanelProps> = ({
  onTriggerSfx,
  onSelectZone,
  activeZone,
}) => {
  const [selectedArchetypeId, setSelectedArchetypeId] =
    useState<string>('method_maestro');
  const [vanityBulbsWarmth, setVanityBulbsWarmth] = useState<
    'warm-gold' | 'daylight-cyan' | 'velvet-rose'
  >('warm-gold');
  const [paparazziBurstCount, setPaparazziBurstCount] = useState<number>(14);

  const selectedArchetype =
    DRESSING_ROOM_ARCHETYPES.find((a) => a.id === selectedArchetypeId) ??
    DRESSING_ROOM_ARCHETYPES[0];

  return (
    <section className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
      {/* Left Column: Star Dressing Room Vanity Mirror & 2.5D Archetype Wardrobe */}
      <div className="lg:col-span-7 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-800">
          <div>
            <div className="text-xs font-mono text-amber-400">
              BACKSTAGE GREEN ROOM · 96 BPM NEO-SOUL RHODES
            </div>
            <h2 className="text-lg font-bold text-white">
              Star Dressing Room &amp; Vanity Mirror Foley Suite
            </h2>
          </div>
          <button
            type="button"
            onClick={() => {
              onSelectZone('star_dressing_room');
              onTriggerSfx('dressing_room_vanity');
            }}
            className={`px-3 py-2 rounded-lg text-xs font-mono font-bold border transition-colors ${
              activeZone === 'star_dressing_room'
                ? 'bg-amber-400 text-slate-950 border-amber-300'
                : 'bg-slate-950 text-amber-300 border-amber-500/50 hover:bg-slate-800'
            }`}
          >
            <span className="inline-flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Activate Dressing Room Music &amp; Vanity Bulbs</span>
            </span>
          </button>
        </div>

        {/* Vanity Mirror Bulb Ring Controls */}
        <div className="p-4 rounded-xl bg-slate-950 border border-slate-800 space-y-3">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <span className="text-xs font-semibold text-slate-200">
              Incandescent Vanity Mirror Ring Lighting (Plays Bulb Chime on Tap)
            </span>
            <div className="flex items-center gap-1.5">
              {(
                [
                  ['warm-gold', 'Warm Limelight Gold'],
                  ['daylight-cyan', 'Soundstage Daylight'],
                  ['velvet-rose', 'After-Hours Rose'],
                ] as const
              ).map(([mode, label]) => (
                <button
                  key={mode}
                  type="button"
                  onClick={() => {
                    setVanityBulbsWarmth(mode);
                    onTriggerSfx('dressing_room_vanity');
                  }}
                  className={`px-2.5 py-1 rounded text-xs font-mono transition-colors ${
                    vanityBulbsWarmth === mode
                      ? 'bg-amber-400 text-slate-950 font-bold'
                      : 'bg-slate-900 text-slate-300 border border-slate-800 hover:border-slate-700'
                  }`}
                >
                  {label}
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
            {DRESSING_ROOM_ARCHETYPES.map((arch) => {
              const isSelected = arch.id === selectedArchetypeId;
              return (
                <button
                  key={arch.id}
                  type="button"
                  onClick={() => {
                    setSelectedArchetypeId(arch.id);
                    onTriggerSfx('dressing_room_vanity');
                  }}
                  className={`text-left p-3.5 rounded-xl border transition-all space-y-1.5 ${
                    isSelected
                      ? 'bg-amber-500/15 border-amber-400 text-white'
                      : 'bg-slate-900 border-slate-800 text-slate-300 hover:border-slate-700'
                  }`}
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-sm font-bold text-white">
                      {arch.name}
                    </span>
                    {isSelected && (
                      <Check className="w-4 h-4 text-amber-400 shrink-0" />
                    )}
                  </div>
                  <div className="text-xs text-amber-200 font-mono">
                    {arch.wardrobe}
                  </div>
                  <div className="text-xs text-slate-400">
                    {arch.eraSpecialty} · {arch.vocalTone}
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Active Actor Wardrobe & Call-Sheet Summary */}
        <div className="p-4 rounded-xl bg-slate-950 border border-slate-800 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="text-xs font-mono text-cyan-400">
              ACTIVE DRESSING ROOM SELECTION
            </div>
            <div className="text-sm font-bold text-white">
              {selectedArchetype.name} — {selectedArchetype.wardrobe}
            </div>
            <div className="text-xs text-slate-400">
              Lighting: {vanityBulbsWarmth.toUpperCase()} · Vocal Warm-Up Ready
            </div>
          </div>
          <button
            type="button"
            onClick={() => onTriggerSfx('clapper_snap')}
            className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-amber-400 hover:bg-amber-300 text-slate-950 text-xs font-mono font-black shrink-0"
          >
            <Clapperboard className="w-4 h-4" />
            <span>STEP ONTO SET (CLAPPER SNAP)</span>
          </button>
        </div>
      </div>

      {/* Right Column: Main Red Carpet Inspiring Anthem & Paparazzi Press Line */}
      <div className="lg:col-span-5 p-6 rounded-xl bg-slate-900 border border-slate-800 space-y-5">
        <div className="space-y-1 pb-3 border-b border-slate-800">
          <div className="text-xs font-mono text-cyan-400">
            MAIN DASHBOARD SOUNDSCAPE · 124 BPM ANTHEM
          </div>
          <h3 className="text-lg font-bold text-white">
            Red Carpet Inspiring Anthem &amp; Live Paparazzi Flash Matrix
          </h3>
          <p className="text-xs text-slate-300 leading-relaxed">
            Motivating superstar progression layered with authentic DSLR camera
            shutters, vintage press flashbulb pops, and high-voltage capacitor
            whines.
          </p>
        </div>

        <div className="p-4 rounded-xl bg-slate-950 border border-slate-800 space-y-3">
          <div className="flex items-center justify-between text-xs">
            <span className="text-slate-400">
              Paparazzi Camera Shutter Bursts Fired
            </span>
            <span className="font-mono font-bold text-cyan-300 tabular-nums">
              {paparazziBurstCount} Flashes
            </span>
          </div>

          <div className="grid grid-cols-1 gap-2.5">
            <button
              type="button"
              onClick={() => {
                setPaparazziBurstCount((c) => c + 3);
                onTriggerSfx('paparazzi_shutter_flash');
              }}
              className="w-full py-3 px-4 rounded-xl bg-cyan-400 hover:bg-cyan-300 text-slate-950 font-mono font-black text-xs inline-flex items-center justify-center gap-2 transition-colors"
            >
              <Camera className="w-4 h-4" />
              <span>FIRE PAPARAZZI CAMERA FLASH &amp; SHUTTER BURST</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onSelectZone('red_carpet_dashboard');
                onTriggerSfx('oscar_trophy_chime');
              }}
              className="w-full py-2.5 px-4 rounded-xl bg-slate-900 hover:bg-slate-800 border border-amber-400/70 text-amber-300 font-mono font-bold text-xs inline-flex items-center justify-center gap-2 transition-colors"
            >
              <Music className="w-4 h-4" />
              <span>PLAY RED CARPET INSPIRING ANTHEM (124 BPM)</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onSelectZone('premiere_entrance');
                onTriggerSfx('oscar_trophy_chime');
              }}
              className="w-full py-2.5 px-4 rounded-xl bg-slate-900 hover:bg-slate-800 border border-purple-400/60 text-purple-200 font-mono font-bold text-xs inline-flex items-center justify-center gap-2 transition-colors"
            >
              <Award className="w-4 h-4" />
              <span>PLAY PREMIERE ENTRANCE OVERTURE (118 BPM)</span>
            </button>
          </div>
        </div>
      </div>
    </section>
  );
};
