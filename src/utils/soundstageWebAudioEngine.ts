import {
  SOUNDSTAGE_ZONES,
  SoundstageAudioSettings,
  SoundstageSfxId,
  SoundstageZoneId,
  shouldPlayChannel,
} from './soundstageAudioLogic';

class SoundstageWebAudioEngine {
  private ctx: AudioContext | null = null;
  private loopTimer: number | null = null;
  private paparazziTimer: number | null = null;
  private stepIndex = 0;
  private currentZone: SoundstageZoneId = 'casting_signup_set';
  private settings: SoundstageAudioSettings = {
    masterEnabled: true,
    musicEnabled: true,
    paparazziAmbienceEnabled: true,
    interactiveSfxEnabled: true,
    masterVolume: 0.75,
  };
  private onPaparazziFlashCallback: (() => void) | null = null;

  private ensureContext(): AudioContext | null {
    if (typeof window === 'undefined') return null;
    if (!this.ctx) {
      const AudioCtx =
        window.AudioContext ||
        (window as unknown as { webkitAudioContext?: typeof AudioContext })
          .webkitAudioContext;
      if (AudioCtx) {
        this.ctx = new AudioCtx();
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume().catch(() => {});
    }
    return this.ctx;
  }

  public setPaparazziFlashListener(cb: (() => void) | null): void {
    this.onPaparazziFlashCallback = cb;
  }

  public syncState(
    zone: SoundstageZoneId,
    settings: SoundstageAudioSettings
  ): void {
    const zoneChanged = this.currentZone !== zone;
    this.currentZone = zone;
    this.settings = settings;

    if (!settings.masterEnabled || settings.masterVolume <= 0) {
      this.stopLoops();
      return;
    }

    if (zoneChanged) {
      this.stepIndex = 0;
      this.restartLoops();
    } else if (!this.loopTimer) {
      this.restartLoops();
    }
  }

  public stopLoops(): void {
    if (this.loopTimer !== null) {
      window.clearInterval(this.loopTimer);
      this.loopTimer = null;
    }
    if (this.paparazziTimer !== null) {
      window.clearInterval(this.paparazziTimer);
      this.paparazziTimer = null;
    }
  }

  private restartLoops(): void {
    this.stopLoops();
    const zoneSpec = SOUNDSTAGE_ZONES[this.currentZone];
    const stepDurationMs = Math.round((60 / zoneSpec.bpm) * 1000 * 0.5); // 8th-note grid

    this.loopTimer = window.setInterval(() => {
      this.playSequencerStep();
    }, stepDurationMs);

    // Ambient foley & paparazzi flash timer
    this.paparazziTimer = window.setInterval(() => {
      if (!shouldPlayChannel(this.settings, 'paparazziAmbienceEnabled')) return;
      if (this.currentZone === 'red_carpet_dashboard') {
        this.playSfx('paparazzi_shutter_flash', true);
        if (this.onPaparazziFlashCallback) {
          this.onPaparazziFlashCallback();
        }
      } else if (this.currentZone === 'star_dressing_room') {
        this.playSfx('dressing_room_vanity', true);
      } else if (this.currentZone === 'casting_signup_set') {
        this.playSfx('call_sheet_stamp', true);
      } else if (this.currentZone === 'premiere_entrance') {
        this.playSfx('paparazzi_shutter_flash', true);
        if (this.onPaparazziFlashCallback) {
          this.onPaparazziFlashCallback();
        }
      }
    }, 3400);
  }

  private playSequencerStep(): void {
    if (!shouldPlayChannel(this.settings, 'musicEnabled')) return;
    const ctx = this.ensureContext();
    if (!ctx || ctx.state !== 'running') return;

    const zone = SOUNDSTAGE_ZONES[this.currentZone];
    const step = this.stepIndex % 16;
    const barIndex = Math.floor(this.stepIndex / 4) % zone.chordProgressionHz.length;
    const vol = this.settings.masterVolume * 0.18;
    const now = ctx.currentTime;

    // 1. Chord Pad / Electric Piano on beat 0 of every 4-step bar
    if (step % 4 === 0) {
      const chord = zone.chordProgressionHz[barIndex];
      chord.forEach((freq, idx) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type =
          this.currentZone === 'red_carpet_dashboard' ||
          this.currentZone === 'premiere_entrance'
            ? 'sawtooth'
            : 'triangle';
        osc.frequency.setValueAtTime(freq, now);

        const filter = ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(
          this.currentZone === 'red_carpet_dashboard' ? 2100 : 1350,
          now
        );

        const noteGain = vol * (0.32 / Math.sqrt(chord.length));
        gain.gain.setValueAtTime(0.0001, now);
        gain.gain.linearRampToValueAtTime(noteGain, now + 0.04 + idx * 0.01);
        gain.gain.exponentialRampToValueAtTime(0.0001, now + 1.05);

        osc.connect(filter);
        filter.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + 1.1);
      });
    }

    // 2. Driving Bassline on steps 0 and 2 of each 4-step bar
    if (step % 2 === 0) {
      const bassFreq =
        zone.basslineHz[barIndex] * (step % 4 === 2 ? 1.5 : 1.0);
      const bassOsc = ctx.createOscillator();
      const bassGain = ctx.createGain();
      bassOsc.type = 'sine';
      bassOsc.frequency.setValueAtTime(bassFreq, now);
      bassGain.gain.setValueAtTime(0.0001, now);
      bassGain.gain.linearRampToValueAtTime(vol * 0.55, now + 0.015);
      bassGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.36);
      bassOsc.connect(bassGain);
      bassGain.connect(ctx.destination);
      bassOsc.start(now);
      bassOsc.stop(now + 0.38);
    }

    // 3. Inspiring Lead Motif Arpeggio
    const motifFreq = zone.leadMotifHz[step % zone.leadMotifHz.length];
    if (
      this.currentZone === 'red_carpet_dashboard' ||
      this.currentZone === 'premiere_entrance' ||
      step % 2 === 1
    ) {
      const leadOsc = ctx.createOscillator();
      const leadGain = ctx.createGain();
      leadOsc.type =
        this.currentZone === 'star_dressing_room' ? 'sine' : 'triangle';
      leadOsc.frequency.setValueAtTime(motifFreq, now);
      leadGain.gain.setValueAtTime(0.0001, now);
      leadGain.gain.linearRampToValueAtTime(vol * 0.28, now + 0.01);
      leadGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.24);
      leadOsc.connect(leadGain);
      leadGain.connect(ctx.destination);
      leadOsc.start(now);
      leadOsc.stop(now + 0.26);
    }

    this.stepIndex++;
  }

  public playSfx(sfxId: SoundstageSfxId, isAmbientFoley = false): void {
    const channelToCheck = isAmbientFoley
      ? 'paparazziAmbienceEnabled'
      : 'interactiveSfxEnabled';
    if (!shouldPlayChannel(this.settings, channelToCheck)) return;

    const ctx = this.ensureContext();
    if (!ctx) return;
    const now = ctx.currentTime;
    const vol =
      this.settings.masterVolume * (isAmbientFoley ? 0.32 : 0.55);

    switch (sfxId) {
      case 'paparazzi_shutter_flash': {
        // Triple rapid DSLR mechanical shutter clicks + vintage flashbulb POP + capacitor recharge WHINE
        [0, 0.085, 0.175].forEach((offset) => {
          this.triggerNoiseBurst(ctx, now + offset, 0.032, 2600, vol * 0.85);
          this.triggerTone(
            ctx,
            now + offset,
            1450,
            620,
            0.035,
            vol * 0.55,
            'square'
          );
        });
        // Vintage Flashbulb capacitor recharge whine (1.6kHz -> 4.3kHz)
        const whineOsc = ctx.createOscillator();
        const whineGain = ctx.createGain();
        whineOsc.type = 'sine';
        whineOsc.frequency.setValueAtTime(1600, now + 0.18);
        whineOsc.frequency.exponentialRampToValueAtTime(4350, now + 0.65);
        whineGain.gain.setValueAtTime(0.0001, now + 0.18);
        whineGain.gain.linearRampToValueAtTime(vol * 0.22, now + 0.25);
        whineGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.68);
        whineOsc.connect(whineGain);
        whineGain.connect(ctx.destination);
        whineOsc.start(now + 0.18);
        whineOsc.stop(now + 0.7);
        break;
      }

      case 'clapper_snap': {
        // Sharp hardwood slate crack + warm resonance
        this.triggerNoiseBurst(ctx, now, 0.045, 1800, vol);
        this.triggerTone(ctx, now, 840, 340, 0.14, vol * 0.75, 'triangle');
        this.triggerTone(ctx, now + 0.01, 1480, 720, 0.09, vol * 0.5, 'sine');
        break;
      }

      case 'film_reel_click': {
        // Crisp 35mm sprocket click
        this.triggerTone(ctx, now, 1920, 960, 0.045, vol * 0.6, 'triangle');
        this.triggerNoiseBurst(ctx, now, 0.02, 3200, vol * 0.4);
        break;
      }

      case 'call_sheet_stamp': {
        // Heavy desk stamp thud + paper snap
        this.triggerTone(ctx, now, 220, 68, 0.12, vol * 0.8, 'sine');
        this.triggerNoiseBurst(ctx, now + 0.02, 0.055, 1400, vol * 0.55);
        break;
      }

      case 'dressing_room_vanity': {
        // Warm incandescent vanity mirror bulb ping + velvet curtain shimmer
        const notes = [587.33, 880.0, 1174.66, 1479.98];
        notes.forEach((freq, i) => {
          this.triggerTone(
            ctx,
            now + i * 0.055,
            freq,
            freq * 1.005,
            0.28,
            vol * 0.35,
            'sine'
          );
        });
        break;
      }

      case 'soundstage_door_thud': {
        // Heavy pneumatic soundstage door lock + air release
        this.triggerTone(ctx, now, 140, 44, 0.35, vol * 0.9, 'sine');
        this.triggerNoiseBurst(ctx, now + 0.08, 0.22, 900, vol * 0.45);
        break;
      }

      case 'oscar_trophy_chime': {
        // Golden Cmaj9 fanfare arpeggio
        const fanfare = [523.25, 659.25, 783.99, 987.77, 1174.66, 1567.98];
        fanfare.forEach((freq, idx) => {
          this.triggerTone(
            ctx,
            now + idx * 0.07,
            freq,
            freq,
            0.55,
            vol * 0.42,
            'triangle'
          );
        });
        break;
      }

      case 'velvet_rope_hook':
      default: {
        // Brass stanchion clip click
        this.triggerTone(ctx, now, 1120, 1680, 0.07, vol * 0.5, 'sine');
        break;
      }
    }
  }

  private triggerTone(
    ctx: AudioContext,
    startTime: number,
    startFreq: number,
    endFreq: number,
    durationSec: number,
    volume: number,
    type: OscillatorType
  ): void {
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = type;
    osc.frequency.setValueAtTime(startFreq, startTime);
    if (startFreq !== endFreq) {
      osc.frequency.exponentialRampToValueAtTime(
        Math.max(20, endFreq),
        startTime + durationSec
      );
    }
    gain.gain.setValueAtTime(0.0001, startTime);
    gain.gain.linearRampToValueAtTime(Math.max(0.001, volume), startTime + 0.008);
    gain.gain.exponentialRampToValueAtTime(0.0001, startTime + durationSec);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(startTime);
    osc.stop(startTime + durationSec + 0.02);
  }

  private triggerNoiseBurst(
    ctx: AudioContext,
    startTime: number,
    durationSec: number,
    centerFreqHz: number,
    volume: number
  ): void {
    const sampleCount = Math.max(1, Math.floor(ctx.sampleRate * durationSec));
    const buffer = ctx.createBuffer(1, sampleCount, ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < sampleCount; i++) {
      data[i] = (Math.random() * 2 - 1) * Math.exp((-i / sampleCount) * 4.5);
    }
    const source = ctx.createBufferSource();
    source.buffer = buffer;

    const filter = ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(centerFreqHz, startTime);
    filter.Q.setValueAtTime(1.8, startTime);

    const gain = ctx.createGain();
    gain.gain.setValueAtTime(Math.max(0.001, volume), startTime);
    gain.gain.exponentialRampToValueAtTime(0.0001, startTime + durationSec);

    source.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);
    source.start(startTime);
    source.stop(startTime + durationSec + 0.01);
  }
}

export const soundstageWebAudio = new SoundstageWebAudioEngine();
