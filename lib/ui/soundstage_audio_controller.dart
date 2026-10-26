import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_settings_modal.dart';

/// The 5 distinct themed audio zones across ACT LIKE IT™.
enum SoundstageZone {
  premiereEntrance,
  castingSignUpSet,
  redCarpetDashboard,
  starDressingRoom,
  afterHoursVault,
}

/// The 8 bespoke theme-related interactive click & foley SFX.
enum SoundstageSfx {
  clapperSnap,
  paparazziShutterFlash,
  filmReelClick,
  callSheetStamp,
  dressingRoomVanity,
  soundstageDoorThud,
  oscarTrophyChime,
  velvetRopeHook,
}

/// Pure-Dart 16-bit PCM WAV Multi-Zone Music & Hollywood Foley Synthesizer.
/// Synthesizes state-of-the-art polyphonic scores and authentic foley effects
/// in memory with zero external network dependencies.
class SoundstageWaveSynthesizer {
  static final Map<SoundstageZone, Uint8List> _zoneMusicCache =
      <SoundstageZone, Uint8List>{};
  static final Map<SoundstageSfx, Uint8List> _sfxCache =
      <SoundstageSfx, Uint8List>{};

  static String zoneTitle(SoundstageZone zone) {
    switch (zone) {
      case SoundstageZone.premiereEntrance:
        return 'PREMIERE GRAND ENTRANCE OVERTURE';
      case SoundstageZone.castingSignUpSet:
        return 'ON-SET CASTING CALL & SIGN-UP GROOVE';
      case SoundstageZone.redCarpetDashboard:
        return 'RED CARPET ANTHEM & PAPARAZZI FRENZY';
      case SoundstageZone.starDressingRoom:
        return 'STAR DRESSING ROOM & VANITY LOUNGE';
      case SoundstageZone.afterHoursVault:
        return 'AFTER-HOURS 18+ VELVET NOIR';
    }
  }

  static String zoneSubtitle(SoundstageZone zone) {
    switch (zone) {
      case SoundstageZone.premiereEntrance:
        return 'Klieg searchlight brass swell, red carpet fanfare & clapperboard strike';
      case SoundstageZone.castingSignUpSet:
        return 'Backstage film-set groove, call-sheet clipboard stamp & stage dimmer clicks';
      case SoundstageZone.redCarpetDashboard:
        return 'Inspiring superstar premiere anthem + live paparazzi DSLR shutters & flashbulbs';
      case SoundstageZone.starDressingRoom:
        return 'Warm neo-soul green-room Rhodes, vanity mirror bulb pings & wardrobe rack foley';
      case SoundstageZone.afterHoursVault:
        return 'Midnight speakeasy Rhodes, upright bass pulse & steel vault lock tumblers';
    }
  }

  /// Synthesizes a rich, seamless 8-second polyphonic loop for each themed zone.
  static Uint8List buildZoneMusicWav(SoundstageZone zone) {
    final cached = _zoneMusicCache[zone];
    if (cached != null) return cached;

    const int sampleRate = 22050;
    const int durationSec = 8;
    const int numSamples = sampleRate * durationSec;
    final Int16List samples = Int16List(numSamples);
    final math.Random rng = math.Random(zone.index + 101);

    late final List<List<double>> chords;
    late final List<double> bass;
    late final List<double> motif;
    late final double bpm;

    switch (zone) {
      case SoundstageZone.premiereEntrance:
        bpm = 118.0;
        chords = const <List<double>>[
          <double>[261.63, 329.63, 392.00, 493.88, 587.33], // Cmaj9
          <double>[293.66, 369.99, 440.00, 523.25, 659.25], // D13
          <double>[349.23, 440.00, 523.25, 659.25, 783.99], // Fmaj9
          <double>[392.00, 493.88, 587.33, 698.46, 880.00], // G13
        ];
        bass = const <double>[130.81, 146.83, 174.61, 196.00];
        motif = const <double>[
          523.25,
          659.25,
          783.99,
          1046.50,
          987.77,
          783.99,
          659.25,
          783.99,
        ];
        break;

      case SoundstageZone.castingSignUpSet:
        bpm = 112.0;
        chords = const <List<double>>[
          <double>[329.63, 392.00, 493.88, 587.33], // Em7
          <double>[220.00, 277.18, 329.63, 440.00], // A9
          <double>[293.66, 369.99, 440.00, 523.25], // Dmaj7
          <double>[246.94, 311.13, 369.99, 493.88], // B7sus4
        ];
        bass = const <double>[82.41, 110.00, 146.83, 123.47];
        motif = const <double>[
          659.25,
          587.33,
          493.88,
          587.33,
          659.25,
          739.99,
          659.25,
          493.88,
        ];
        break;

      case SoundstageZone.redCarpetDashboard:
        bpm = 124.0;
        chords = const <List<double>>[
          <double>[220.00, 277.18, 329.63, 415.30, 493.88], // Amaj9
          <double>[185.00, 220.00, 277.18, 329.63, 415.30], // F#m9
          <double>[293.66, 369.99, 440.00, 554.37, 659.25], // Dmaj9
          <double>[329.63, 415.30, 493.88, 587.33, 739.99], // E13
        ];
        bass = const <double>[110.00, 92.50, 146.83, 164.81];
        motif = const <double>[
          440.00,
          554.37,
          659.25,
          880.00,
          830.61,
          659.25,
          739.99,
          880.00,
        ];
        break;

      case SoundstageZone.starDressingRoom:
        bpm = 96.0;
        chords = const <List<double>>[
          <double>[174.61, 220.00, 261.63, 329.63, 392.00], // Fmaj9
          <double>[164.81, 196.00, 246.94, 293.66, 349.23], // Em7b5/A7
          <double>[146.83, 174.61, 220.00, 261.63, 329.63], // Dm9
          <double>[196.00, 233.08, 293.66, 349.23, 440.00], // Gm9/C13
        ];
        bass = const <double>[87.31, 82.41, 73.42, 98.00];
        motif = const <double>[
          523.25,
          440.00,
          392.00,
          349.23,
          440.00,
          523.25,
          587.33,
          523.25,
        ];
        break;

      case SoundstageZone.afterHoursVault:
        bpm = 88.0;
        chords = const <List<double>>[
          <double>[261.63, 311.13, 392.00, 466.16, 587.33], // Cm11
          <double>[207.65, 261.63, 311.13, 392.00, 466.16], // Abmaj9
          <double>[174.61, 207.65, 261.63, 311.13, 392.00], // Fm9
          <double>[196.00, 246.94, 293.66, 349.23, 415.30], // G7alt
        ];
        bass = const <double>[65.41, 103.83, 87.31, 98.00];
        motif = const <double>[
          523.25,
          466.16,
          392.00,
          311.13,
          349.23,
          392.00,
          311.13,
          261.63,
        ];
        break;
    }

    final double barSec = 2.0; // 4 bars across 8 seconds
    final double stepSec = 60.0 / bpm / 2.0; // 8th-note pulse

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final int barIdx = (t ~/ barSec) % chords.length;
      final double barLocalT = t % barSec;
      final int stepIdx = (t ~/ stepSec);
      final double stepLocalT = t % stepSec;

      double signal = 0.0;

      // 1. Warm Polyphonic Chord Pad / Electric Piano
      final List<double> chord = chords[barIdx];
      final double chordEnv =
          (1.0 - math.exp(-barLocalT * 24.0)) * math.exp(-barLocalT * 1.15);
      for (int c = 0; c < chord.length; c++) {
        final double freq = chord[c];
        signal += (math.sin(2.0 * math.pi * freq * t) * 0.075 +
                math.sin(2.0 * math.pi * (freq * 2.0) * t) * 0.022) *
            chordEnv;
      }

      // 2. Motivating Bassline Pulse
      final double bassFreq =
          bass[barIdx] * ((stepIdx % 4 == 2) ? 1.5 : 1.0);
      final double bassEnv =
          (1.0 - math.exp(-stepLocalT * 45.0)) * math.exp(-stepLocalT * 6.5);
      signal += (math.sin(2.0 * math.pi * bassFreq * t) * 0.22 +
              math.sin(2.0 * math.pi * (bassFreq * 2.0) * t) * 0.08) *
          bassEnv;

      // 3. Lead Arpeggio / Inspiring Motif
      final double leadFreq = motif[stepIdx % motif.length];
      final double leadEnv =
          (1.0 - math.exp(-stepLocalT * 55.0)) * math.exp(-stepLocalT * 7.5);
      signal += (math.sin(2.0 * math.pi * leadFreq * t) * 0.12 +
              math.sin(2.0 * math.pi * (leadFreq * 1.5) * t) * 0.035) *
          leadEnv;

      // 4. Subtle Studio Percussion / Set Rhythm
      if (zone == SoundstageZone.redCarpetDashboard ||
          zone == SoundstageZone.castingSignUpSet ||
          zone == SoundstageZone.premiereEntrance) {
        if (stepLocalT < 0.035 && stepIdx % 2 == 1) {
          final double hatEnv = math.exp(-stepLocalT * 95.0);
          signal += (rng.nextDouble() * 2.0 - 1.0) * 0.08 * hatEnv;
        }
      }

      // Smooth crossfade at loop boundary
      double loopEnv = 1.0;
      if (t < 0.08) {
        loopEnv = t / 0.08;
      } else if (t > durationSec - 0.12) {
        loopEnv = (durationSec - t) / 0.12;
      }

      final int pcm = ((signal * loopEnv).clamp(-0.88, 0.88) * 32767.0).round();
      samples[i] = pcm.clamp(-32768, 32767);
    }

    final Uint8List wav = _encodePcm16MonoWav(samples, sampleRate);
    _zoneMusicCache[zone] = wav;
    return wav;
  }

  /// Synthesizes bespoke Hollywood foley & prop SFX for every interaction and ambient cue.
  static Uint8List buildSfxWav(SoundstageSfx sfx) {
    final cached = _sfxCache[sfx];
    if (cached != null) return cached;

    const int sampleRate = 22050;
    final math.Random rng = math.Random(sfx.index + 303);
    late final Int16List samples;

    switch (sfx) {
      case SoundstageSfx.paparazziShutterFlash:
        // Rapid triple DSLR mechanical shutter burst + vintage flashbulb POP + capacitor recharge WHINE
        const double dur = 0.78;
        final int count = (sampleRate * dur).round();
        samples = Int16List(count);
        double whinePhase = 0.0;
        for (int i = 0; i < count; i++) {
          final double t = i / sampleRate;
          double sig = 0.0;

          // 3 rapid camera shutter clicks at 0.00s, 0.09s, 0.18s
          for (final double offset in const <double>[0.0, 0.09, 0.18]) {
            if (t >= offset && t < offset + 0.045) {
              final double dt = t - offset;
              final double clickEnv = math.exp(-dt * 75.0);
              final double mirrorSlap =
                  math.sin(2.0 * math.pi * (1420.0 - dt * 9000.0) * dt) * 0.55;
              final double shutterCurtain =
                  (rng.nextDouble() * 2.0 - 1.0) * 0.65;
              sig += (mirrorSlap + shutterCurtain) * clickEnv;
            }
          }

          // Flashbulb capacitor recharge whine (1.65kHz -> 4.35kHz)
          if (t >= 0.16) {
            final double dt = ((t - 0.16) / 0.60).clamp(0.0, 1.0);
            final double instFreq =
                1650.0 + 2700.0 * Curves.easeOutQuad.transform(dt);
            whinePhase += (2.0 * math.pi * instFreq) / sampleRate;
            final double whineEnv = math.sin(dt * math.pi) * 0.25;
            sig += math.sin(whinePhase) * whineEnv;
          }

          samples[i] = (sig.clamp(-0.92, 0.92) * 32767.0).round();
        }
        break;

      case SoundstageSfx.clapperSnap:
        const double dur = 0.38;
        final int count = (sampleRate * dur).round();
        samples = Int16List(count);
        for (int i = 0; i < count; i++) {
          final double t = i / sampleRate;
          final double env = math.exp(-t * 32.0);
          final double wood = math.sin(2.0 * math.pi * 840.0 * t) * 0.48 +
              math.sin(2.0 * math.pi * 1490.0 * t) * 0.32 +
              math.sin(2.0 * math.pi * 350.0 * t) * 0.25;
          final double crack =
              (rng.nextDouble() * 2.0 - 1.0) * math.exp(-t * 55.0) * 0.6;
          samples[i] =
              (((wood * env) + crack).clamp(-0.92, 0.92) * 32767.0).round();
        }
        break;

      case SoundstageSfx.filmReelClick:
        const double dur = 0.16;
        final int count = (sampleRate * dur).round();
        samples = Int16List(count);
        for (int i = 0; i < count; i++) {
          final double t = i / sampleRate;
          final double env = math.exp(-t * 58.0);
          final double sprocket =
              math.sin(2.0 * math.pi * 1880.0 * t) * 0.55 +
                  (rng.nextDouble() * 2.0 - 1.0) * 0.35;
          samples[i] = ((sprocket * env).clamp(-0.9, 0.9) * 32767.0).round();
        }
        break;

      case SoundstageSfx.callSheetStamp:
        const double dur = 0.34;
        final int count = (sampleRate * dur).round();
        samples = Int16List(count);
        for (int i = 0; i < count; i++) {
          final double t = i / sampleRate;
          final double thudEnv = math.exp(-t * 28.0);
          final double thud =
              math.sin(2.0 * math.pi * (190.0 - t * 320.0) * t) * 0.65;
          final double paperSnap = t >= 0.025
              ? (rng.nextDouble() * 2.0 - 1.0) *
                  math.exp(-(t - 0.025) * 45.0) *
                  0.45
              : 0.0;
          samples[i] =
              (((thud * thudEnv) + paperSnap).clamp(-0.9, 0.9) * 32767.0)
                  .round();
        }
        break;

      case SoundstageSfx.dressingRoomVanity:
        // Warm incandescent vanity bulb chime + silk wardrobe rack shimmer
        const double dur = 0.55;
        final int count = (sampleRate * dur).round();
        samples = Int16List(count);
        const List<double> bulbNotes = <double>[587.33, 880.0, 1174.66, 1479.98];
        for (int i = 0; i < count; i++) {
          final double t = i / sampleRate;
          double sig = 0.0;
          for (int n = 0; n < bulbNotes.length; n++) {
            final double start = n * 0.06;
            if (t >= start) {
              final double dt = t - start;
              final double env =
                  (1.0 - math.exp(-dt * 60.0)) * math.exp(-dt * 8.5);
              sig += math.sin(2.0 * math.pi * bulbNotes[n] * dt) * 0.25 * env;
            }
          }
          samples[i] = (sig.clamp(-0.9, 0.9) * 32767.0).round();
        }
        break;

      case SoundstageSfx.soundstageDoorThud:
        const double dur = 0.52;
        final int count = (sampleRate * dur).round();
        samples = Int16List(count);
        for (int i = 0; i < count; i++) {
          final double t = i / sampleRate;
          final double env = math.exp(-t * 14.0);
          final double sub =
              math.sin(2.0 * math.pi * (135.0 - t * 140.0) * t) * 0.72;
          final double air = (rng.nextDouble() * 2.0 - 1.0) * 0.28 * env;
          samples[i] = (((sub * env) + air).clamp(-0.9, 0.9) * 32767.0).round();
        }
        break;

      case SoundstageSfx.oscarTrophyChime:
        const double dur = 0.88;
        final int count = (sampleRate * dur).round();
        samples = Int16List(count);
        const List<double> fanfare = <double>[
          523.25,
          659.25,
          783.99,
          987.77,
          1174.66,
          1567.98,
        ];
        for (int i = 0; i < count; i++) {
          final double t = i / sampleRate;
          double sig = 0.0;
          for (int n = 0; n < fanfare.length; n++) {
            final double start = n * 0.065;
            if (t >= start) {
              final double dt = t - start;
              final double env =
                  (1.0 - math.exp(-dt * 50.0)) * math.exp(-dt * 4.8);
              sig += math.sin(2.0 * math.pi * fanfare[n] * dt) * 0.22 * env;
            }
          }
          samples[i] = (sig.clamp(-0.9, 0.9) * 32767.0).round();
        }
        break;

      case SoundstageSfx.velvetRopeHook:
        const double dur = 0.18;
        final int count = (sampleRate * dur).round();
        samples = Int16List(count);
        for (int i = 0; i < count; i++) {
          final double t = i / sampleRate;
          final double env = math.exp(-t * 42.0);
          final double freq = 1120.0 + t * 2800.0;
          final double sig = math.sin(2.0 * math.pi * freq * t) * 0.55 * env;
          samples[i] = (sig.clamp(-0.9, 0.9) * 32767.0).round();
        }
        break;
    }

    final Uint8List wav = _encodePcm16MonoWav(samples, sampleRate);
    _sfxCache[sfx] = wav;
    return wav;
  }

  static Uint8List _encodePcm16MonoWav(Int16List samples, int sampleRate) {
    final int dataSize = samples.length * 2;
    final ByteData buffer = ByteData(44 + dataSize);
    const List<int> riff = <int>[0x52, 0x49, 0x46, 0x46]; // "RIFF"
    const List<int> wave = <int>[0x57, 0x41, 0x56, 0x45]; // "WAVE"
    const List<int> fmt = <int>[0x66, 0x6D, 0x74, 0x20]; // "fmt "
    const List<int> data = <int>[0x64, 0x61, 0x74, 0x61]; // "data"

    for (int i = 0; i < 4; i++) {
      buffer.setUint8(i, riff[i]);
      buffer.setUint8(8 + i, wave[i]);
      buffer.setUint8(12 + i, fmt[i]);
      buffer.setUint8(36 + i, data[i]);
    }
    buffer.setUint32(4, 36 + dataSize, Endian.little);
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little);
    buffer.setUint16(22, 1, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little);
    buffer.setUint16(32, 2, Endian.little);
    buffer.setUint16(34, 16, Endian.little);
    buffer.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < samples.length; i++) {
      buffer.setInt16(44 + i * 2, samples[i], Endian.little);
    }
    return buffer.buffer.asUint8List();
  }
}

/// Global Multi-Zone Soundstage Audio & Foley Controller.
/// Controls background theme music per screen, periodic Paparazzi camera shutter
/// bursts & dressing room ambience, and unique prop click SFX with persistent
/// user toggles accessible from the Sign-In/Sign-Up menu, Dressing Room,
/// Red Carpet Dashboard, and Settings Modal.
class SoundstageAudioController extends ChangeNotifier {
  static final SoundstageAudioController instance =
      SoundstageAudioController._internal();

  SoundstageAudioController._internal();

  static const String _kPrefMasterEnabled = 'ali_audio_master_enabled_v2';
  static const String _kPrefMusicEnabled = 'ali_audio_music_enabled_v2';
  static const String _kPrefPaparazziEnabled = 'ali_audio_paparazzi_enabled_v2';
  static const String _kPrefSfxEnabled = 'ali_audio_sfx_enabled_v2';
  static const String _kPrefMasterVolume = 'ali_audio_master_volume_v2';

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _ambiencePlayer = AudioPlayer();

  Timer? _ambienceLoopTimer;
  SoundstageZone _activeZone = SoundstageZone.castingSignUpSet;
  bool _initialized = false;

  bool _masterEnabled = true;
  bool _musicEnabled = true;
  bool _paparazziAmbienceEnabled = true;
  bool _interactiveSfxEnabled = true;
  double _masterVolume = 0.65;

  VoidCallback? onPaparazziFlashVisual;

  SoundstageZone get activeZone => _activeZone;
  bool get masterEnabled => _masterEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get paparazziAmbienceEnabled => _paparazziAmbienceEnabled;
  bool get interactiveSfxEnabled => _interactiveSfxEnabled;
  double get masterVolume => _masterVolume;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _masterEnabled = prefs.getBool(_kPrefMasterEnabled) ?? true;
      _musicEnabled = prefs.getBool(_kPrefMusicEnabled) ?? true;
      _paparazziAmbienceEnabled =
          prefs.getBool(_kPrefPaparazziEnabled) ?? true;
      _interactiveSfxEnabled = prefs.getBool(_kPrefSfxEnabled) ?? true;
      _masterVolume = prefs.getDouble(_kPrefMasterVolume) ?? 0.65;
      GameSettingsModal.masterAudioVolume = _masterVolume;
    } catch (_) {}
    _startAmbienceTimer();
    notifyListeners();
  }

  Future<void> _persistSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefMasterEnabled, _masterEnabled);
      await prefs.setBool(_kPrefMusicEnabled, _musicEnabled);
      await prefs.setBool(_kPrefPaparazziEnabled, _paparazziAmbienceEnabled);
      await prefs.setBool(_kPrefSfxEnabled, _interactiveSfxEnabled);
      await prefs.setDouble(_kPrefMasterVolume, _masterVolume);
    } catch (_) {}
  }

  Future<void> enterZone(SoundstageZone zone, {bool forceRestart = false}) async {
    await ensureInitialized();
    final bool zoneChanged = _activeZone != zone;
    _activeZone = zone;
    notifyListeners();

    if (!_masterEnabled || !_musicEnabled || _masterVolume <= 0.0) {
      try {
        await _musicPlayer.pause();
      } catch (_) {}
      return;
    }

    if (zoneChanged || forceRestart || _musicPlayer.state != PlayerState.playing) {
      try {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer.setVolume((_masterVolume * 0.55).clamp(0.0, 1.0));
        final Uint8List wavBytes =
            SoundstageWaveSynthesizer.buildZoneMusicWav(zone);
        await _musicPlayer.play(BytesSource(wavBytes));
      } catch (_) {}
    }
  }

  void _startAmbienceTimer() {
    _ambienceLoopTimer?.cancel();
    _ambienceLoopTimer = Timer.periodic(
      const Duration(milliseconds: 3800),
      (_) {
        if (!_masterEnabled || !_paparazziAmbienceEnabled || _masterVolume <= 0) {
          return;
        }
        switch (_activeZone) {
          case SoundstageZone.redCarpetDashboard:
          case SoundstageZone.premiereEntrance:
            unawaited(
              playSfx(
                SoundstageSfx.paparazziShutterFlash,
                isAmbientLayer: true,
              ),
            );
            onPaparazziFlashVisual?.call();
            break;
          case SoundstageZone.starDressingRoom:
            unawaited(
              playSfx(
                SoundstageSfx.dressingRoomVanity,
                isAmbientLayer: true,
              ),
            );
            break;
          case SoundstageZone.castingSignUpSet:
            unawaited(
              playSfx(
                SoundstageSfx.callSheetStamp,
                isAmbientLayer: true,
              ),
            );
            break;
          case SoundstageZone.afterHoursVault:
            unawaited(
              playSfx(
                SoundstageSfx.filmReelClick,
                isAmbientLayer: true,
              ),
            );
            break;
        }
      },
    );
  }

  Future<void> playSfx(
    SoundstageSfx sfx, {
    bool isAmbientLayer = false,
  }) async {
    if (!_masterEnabled || _masterVolume <= 0.0) return;
    if (isAmbientLayer && !_paparazziAmbienceEnabled) return;
    if (!isAmbientLayer && !_interactiveSfxEnabled) return;

    try {
      final AudioPlayer targetPlayer =
          isAmbientLayer ? _ambiencePlayer : _sfxPlayer;
      final double vol = isAmbientLayer
          ? (_masterVolume * 0.42).clamp(0.0, 1.0)
          : (_masterVolume * 0.78).clamp(0.0, 1.0);
      await targetPlayer.setVolume(vol);
      final Uint8List wavBytes = SoundstageWaveSynthesizer.buildSfxWav(sfx);
      await targetPlayer.play(BytesSource(wavBytes));
    } catch (_) {}
  }

  Future<void> toggleMasterEnabled() async {
    HapticFeedback.selectionClick();
    _masterEnabled = !_masterEnabled;
    await _persistSettings();
    notifyListeners();
    if (_masterEnabled) {
      await playSfx(SoundstageSfx.velvetRopeHook);
      await enterZone(_activeZone, forceRestart: true);
    } else {
      try {
        await _musicPlayer.pause();
        await _ambiencePlayer.stop();
      } catch (_) {}
    }
  }

  Future<void> toggleMusicEnabled() async {
    HapticFeedback.selectionClick();
    _musicEnabled = !_musicEnabled;
    await _persistSettings();
    notifyListeners();
    await playSfx(SoundstageSfx.velvetRopeHook);
    if (_musicEnabled && _masterEnabled) {
      await enterZone(_activeZone, forceRestart: true);
    } else {
      try {
        await _musicPlayer.pause();
      } catch (_) {}
    }
  }

  Future<void> togglePaparazziAmbienceEnabled() async {
    HapticFeedback.selectionClick();
    _paparazziAmbienceEnabled = !_paparazziAmbienceEnabled;
    await _persistSettings();
    notifyListeners();
    if (_paparazziAmbienceEnabled && _masterEnabled) {
      await playSfx(SoundstageSfx.paparazziShutterFlash, isAmbientLayer: true);
    }
  }

  Future<void> toggleInteractiveSfxEnabled() async {
    HapticFeedback.selectionClick();
    _interactiveSfxEnabled = !_interactiveSfxEnabled;
    await _persistSettings();
    notifyListeners();
    if (_interactiveSfxEnabled && _masterEnabled) {
      await playSfx(SoundstageSfx.clapperSnap);
    }
  }

  Future<void> setMasterVolume(double value) async {
    _masterVolume = value.clamp(0.0, 1.0);
    GameSettingsModal.masterAudioVolume = _masterVolume;
    GameSettingsModal.volumeNotifier.value = _masterVolume;
    await _persistSettings();
    notifyListeners();
    try {
      await _musicPlayer.setVolume((_masterVolume * 0.55).clamp(0.0, 1.0));
    } catch (_) {}
  }

  Future<void> pauseAllForBackground() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeIfEnabled() async {
    if (_masterEnabled && _musicEnabled) {
      await enterZone(_activeZone, forceRestart: false);
    }
  }
}

/// Compact, high-contrast Hollywood Soundstage Audio Console Bar that can be
/// embedded directly on the Sign-In / Sign-Up Menu, NDA Gate, Dressing Room,
/// and Main Red Carpet Dashboard so the user can toggle every part of the
/// music and sound effects on or off at any time.
class SoundstageAudioConsoleBar extends StatelessWidget {
  final SoundstageZone zone;
  final bool compact;

  const SoundstageAudioConsoleBar({
    super.key,
    required this.zone,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SoundstageAudioController.instance;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final bool masterOn = controller.masterEnabled;
        final bool musicOn = masterOn && controller.musicEnabled;
        final bool ambienceOn = masterOn && controller.paparazziAmbienceEnabled;
        final bool sfxOn = masterOn && controller.interactiveSfxEnabled;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0E17).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: masterOn
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.65)
                  : const Color(0xFF334155),
              width: 1.4,
            ),
            boxShadow: <BoxShadow>[
              if (masterOn)
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    masterOn
                        ? Icons.graphic_eq_rounded
                        : Icons.volume_off_rounded,
                    color: masterOn
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF64748B),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'STUDIO SOUNDSCAPE · ${SoundstageWaveSynthesizer.zoneTitle(zone)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Color(0xFFFDE68A),
                          ),
                        ),
                        if (!compact)
                          Text(
                            SoundstageWaveSynthesizer.zoneSubtitle(zone),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (zone == SoundstageZone.redCarpetDashboard ||
                      zone == SoundstageZone.premiereEntrance)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: InkWell(
                        onTap: () {
                          controller.playSfx(
                            SoundstageSfx.paparazziShutterFlash,
                          );
                          controller.onPaparazziFlashVisual?.call();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF06B6D4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 12,
                                color: Color(0xFF67E8F9),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'FLASH',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF67E8F9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  _buildChannelChip(
                    label: masterOn ? 'MASTER: ON' : 'MASTER: OFF',
                    icon: masterOn
                        ? Icons.power_settings_new_rounded
                        : Icons.power_off_rounded,
                    active: masterOn,
                    activeColor: const Color(0xFF10B981),
                    onTap: () => controller.toggleMasterEnabled(),
                  ),
                  _buildChannelChip(
                    label: musicOn ? 'MUSIC: ON' : 'MUSIC: OFF',
                    icon: Icons.music_note_rounded,
                    active: musicOn,
                    activeColor: const Color(0xFFF59E0B),
                    onTap: () => controller.toggleMusicEnabled(),
                  ),
                  _buildChannelChip(
                    label: ambienceOn ? 'PAPARAZZI/SET: ON' : 'PAPARAZZI/SET: OFF',
                    icon: Icons.camera_enhance_rounded,
                    active: ambienceOn,
                    activeColor: const Color(0xFF06B6D4),
                    onTap: () => controller.togglePaparazziAmbienceEnabled(),
                  ),
                  _buildChannelChip(
                    label: sfxOn ? 'CLICK SFX: ON' : 'CLICK SFX: OFF',
                    icon: Icons.movie_creation_outlined,
                    active: sfxOn,
                    activeColor: const Color(0xFFA855F7),
                    onTap: () => controller.toggleInteractiveSfxEnabled(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelChip({
    required String label,
    required IconData icon,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.18)
              : const Color(0xFF07090E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? activeColor : const Color(0xFF334155),
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 12,
              color: active ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
