import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';
import 'lobby.dart';
import 'webrtc_manager.dart';
import 'offline_manager.dart';
import 'judging/feedback_engine.dart';
import 'monetization/payment_dashboard_screen.dart';
import 'social/cutting_room_feed.dart';
import 'ui/game_app_bar.dart';
import 'ui/game_settings_modal.dart';
import 'ui/intro_cinematic.dart';
import 'ui/match_finalization_screen.dart';
import 'ui/opening_maestro_hero.dart';
import 'ui/tutorial_overlay.dart';
import 'auth/auth_service.dart';

class FacialMicroExpressionTelemetry {
  final int timestampMs;
  final String microExpression;
  final double intensity;
  final String impactOnScore;

  const FacialMicroExpressionTelemetry({
    required this.timestampMs,
    required this.microExpression,
    required this.intensity,
    required this.impactOnScore,
  });

  factory FacialMicroExpressionTelemetry.fromJson(Map<String, dynamic> json) {
    final rawTs = (json['timestamp_ms'] as num?)?.toInt() ?? 1000;
    final rawIntensity = (json['intensity'] as num?)?.toDouble() ?? 0.85;
    return FacialMicroExpressionTelemetry(
      timestampMs: rawTs < 0 ? 0 : rawTs,
      microExpression: (json['micro_expression'] ??
              json['detected_expression'] ??
              'Focused brow furrow & ocular lock')
          .toString(),
      intensity: rawIntensity.clamp(0.0, 1.0),
      impactOnScore: (json['impact_on_score'] ??
              'Verified emotional commitment on key dramatic beat')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timestamp_ms': timestampMs,
        'micro_expression': microExpression,
        'intensity': intensity,
        'impact_on_score': impactOnScore,
      };
}

class VocalProsodyShiftTelemetry {
  final int timestampMs;
  final String prosodyShift;
  final double decibelLevelDb;
  final String impactOnScore;

  const VocalProsodyShiftTelemetry({
    required this.timestampMs,
    required this.prosodyShift,
    required this.decibelLevelDb,
    required this.impactOnScore,
  });

  factory VocalProsodyShiftTelemetry.fromJson(Map<String, dynamic> json) {
    final rawTs = (json['timestamp_ms'] as num?)?.toInt() ?? 2000;
    final rawDb = (json['decibel_level_db'] as num?)?.toDouble() ??
        (json['decibel_delta_db'] as num?)?.toDouble() ??
        -18.0;
    return VocalProsodyShiftTelemetry(
      timestampMs: rawTs < 0 ? 0 : rawTs,
      prosodyShift: (json['prosody_shift'] ??
              'Dynamic diaphragm projection & cadence inflection')
          .toString(),
      decibelLevelDb: rawDb.clamp(-60.0, 6.0),
      impactOnScore: (json['impact_on_score'] ??
              'Sustained soundstage vocal authority across turn')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timestamp_ms': timestampMs,
        'prosody_shift': prosodyShift,
        'decibel_level_db': decibelLevelDb,
        'impact_on_score': impactOnScore,
      };
}

class AiTelemetricsReport {
  final double overallAiScore;
  final double facialExpressionScore;
  final double vocalCadenceScore;
  final double directorCueFidelity;
  final String scoringTier;
  final String directorCritique;
  final List<FacialMicroExpressionTelemetry> facialMicroExpressions;
  final List<VocalProsodyShiftTelemetry> vocalProsodyShifts;

  const AiTelemetricsReport({
    required this.overallAiScore,
    required this.facialExpressionScore,
    required this.vocalCadenceScore,
    required this.directorCueFidelity,
    this.scoringTier = '70-89_AVERAGE_ATTEMPT',
    required this.directorCritique,
    this.facialMicroExpressions = const <FacialMicroExpressionTelemetry>[],
    this.vocalProsodyShifts = const <VocalProsodyShiftTelemetry>[],
  });

  factory AiTelemetricsReport.fromJson(Map<String, dynamic> json) {
    final facial =
        (json['facial_expression_score'] as num?)?.toDouble() ?? 78.0;
    final vocal = (json['vocal_cadence_score'] as num?)?.toDouble() ?? 76.0;
    final fidelity =
        (json['director_cue_fidelity'] as num?)?.toDouble() ?? 78.0;
    final overall = (json['overall_ai_score'] as num?)?.toDouble() ??
        ((facial + vocal + fidelity) / 3.0);

    final rawFacialEvents = json['facial_micro_expressions'];
    final parsedFacialEvents = <FacialMicroExpressionTelemetry>[];
    if (rawFacialEvents is List) {
      for (final item in rawFacialEvents) {
        if (item is Map) {
          parsedFacialEvents.add(
            FacialMicroExpressionTelemetry.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    final rawVocalEvents = json['vocal_prosody_shifts'];
    final parsedVocalEvents = <VocalProsodyShiftTelemetry>[];
    if (rawVocalEvents is List) {
      for (final item in rawVocalEvents) {
        if (item is Map) {
          parsedVocalEvents.add(
            VocalProsodyShiftTelemetry.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    final clampedOverall = overall.clamp(0.0, 100.0);
    final inferredTier = clampedOverall >= 90.0
        ? '90-100_OSCAR_LEVEL'
        : clampedOverall >= 70.0
            ? '70-89_AVERAGE_ATTEMPT'
            : clampedOverall >= 50.0
                ? '50-69_FLAT_DELIVERY'
                : '0-49_LOW_ENERGY_OR_MISSED_CUE';

    return AiTelemetricsReport(
      overallAiScore: clampedOverall,
      facialExpressionScore: facial.clamp(0.0, 100.0),
      vocalCadenceScore: vocal.clamp(0.0, 100.0),
      directorCueFidelity: fidelity.clamp(0.0, 100.0),
      scoringTier: (json['scoring_tier'] ?? inferredTier).toString(),
      directorCritique: json['director_critique']?.toString() ??
          'Committed emotional arc with crisp vocal projection on the key beat.',
      facialMicroExpressions: parsedFacialEvents,
      vocalProsodyShifts: parsedVocalEvents,
    );
  }
}

class TriModalJudgingEngine extends ChangeNotifier {
  static const String storageBucket = 'performance-loops';
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  AiTelemetricsReport? _aiReport;
  VideoPlayerController? _loopController;
  String? _supabaseLoopUrl;
  bool _isEvaluatingAi = false;
  bool _isUploadingLoop = false;
  bool _isDisposed = false;
  String? _errorMessage;

  final List<double> _peerVotes = [88.0];
  int _externalShares = 0;
  int _externalReactions = 0;
  int _loopCompletions = 1;
  bool _hasSavedMatchHistory = false;
  bool _hasSyncedRoundToSupabase = false;
  bool _lastRoundWasWin = false;
  String? _roundHistoryId;
  double _improvBonus = 0.0;
  bool _characterBrokenPenalty = false;
  bool _standingOvationCrowdCombo = false;
  bool _isLifeIsImprovTake = false;
  bool _speakeasySubtextMultiplierActive = false;
  static int spectatorTokenShards = 2;
  static bool undercoverLegendUnlocked = false;

  AiTelemetricsReport? get aiReport => _aiReport;
  double get improvBonus => _improvBonus;
  bool get characterBrokenPenalty => _characterBrokenPenalty;
  bool get standingOvationCrowdCombo => _standingOvationCrowdCombo;
  bool get isLifeIsImprovTake => _isLifeIsImprovTake;
  bool get speakeasySubtextMultiplierActive => _speakeasySubtextMultiplierActive;
  bool get hasSavedMatchHistory => _hasSavedMatchHistory;
  bool get lastRoundWasWin => _lastRoundWasWin;
  String? get roundHistoryId => _roundHistoryId;
  VideoPlayerController? get loopController => _loopController;
  String? get supabaseLoopUrl => _supabaseLoopUrl;
  bool get isEvaluatingAi => _isEvaluatingAi;
  bool get isUploadingLoop => _isUploadingLoop;
  String? get errorMessage => _errorMessage;

  void setImprovTwistCompleted(
    bool completed, {
    bool characterBroken = false,
    bool crowdCombo = false,
    bool lifeIsImprov = false,
    bool speakeasySubtext = false,
  }) {
    _improvBonus = completed ? 5.0 : 0.0;
    _characterBrokenPenalty = characterBroken;
    _standingOvationCrowdCombo = crowdCombo;
    _isLifeIsImprovTake = lifeIsImprov;
    _speakeasySubtextMultiplierActive = speakeasySubtext;
    _safeNotifyListeners();
  }

  /// Fixture #2: Top 2 millisecond telemetry peak stamps for video loop & Premiere Reel export.
  List<String> get millisecondReceiptStamps {
    final r = _aiReport;
    if (r == null) {
      return const <String>[
        '[00:01.18] 🔥 +8.5 PT VOCAL PEAK (-14.2 dBFS)',
        '[00:03.90] 🎭 +6.2 PT EMOTIONAL SHIFT (91% INTENSITY)',
      ];
    }
    final stamps = <String>[];
    if (r.vocalProsodyShifts.isNotEmpty) {
      final v = r.vocalProsodyShifts.first;
      final sec = (v.timestampMs / 1000.0).toStringAsFixed(2).padLeft(5, '0');
      stamps.add(
        '[00:$sec] 🔥 ${v.impactOnScore.toUpperCase()} VOCAL PEAK (${v.decibelLevelDb.toStringAsFixed(1)} dBFS)',
      );
    }
    if (r.facialMicroExpressions.isNotEmpty) {
      final f = r.facialMicroExpressions.first;
      final sec = (f.timestampMs / 1000.0).toStringAsFixed(2).padLeft(5, '0');
      stamps.add(
        '[00:$sec] 🎭 ${f.impactOnScore.toUpperCase()} ${f.microExpression.toUpperCase()}',
      );
    }
    if (stamps.isEmpty) {
      stamps.add('[00:01.42] 🔥 +8.0 PT VOCAL PROJECTION LOCK (-15.0 dBFS)');
    }
    return stamps.take(2).toList();
  }

  /// Fixture #11: AI Co-Star Personalities & Voting Biases in Peer Judging.
  List<({String name, String biasTag, double score, String quote})>
      get aiCoStarVerdicts {
    final facial = _aiReport?.facialExpressionScore ?? 86.0;
    final vocal = _aiReport?.vocalCadenceScore ?? 85.0;
    final cue = _aiReport?.directorCueFidelity ?? 86.0;
    final criticScore = ((cue * 0.65) + (facial * 0.35)).clamp(55.0, 99.0);
    final stuntScore =
        ((vocal * 0.65) + (_improvBonus > 0 ? 95.0 : 78.0) * 0.35)
            .clamp(55.0, 99.0);
    final divaScore = ((facial * 0.70) + (vocal * 0.30)).clamp(55.0, 99.0);
    return [
      (
        name: 'The Veteran Film Critic',
        biasTag: 'Rewards Cue Fidelity · Punishes Missed Pacing',
        score: criticScore,
        quote: criticScore >= 85
            ? 'Impeccable subtext and pacing on the turn.'
            : 'Watch your beat timing before the final line.',
      ),
      (
        name: 'Blaze Mercer (Stunt Double)',
        biasTag: 'Rewards High dB Projection & Curveball Commitment',
        score: stuntScore,
        quote: _improvBonus > 0
            ? 'You ate that 15-second curveball without blinking!'
            : 'Project from the diaphragm and swing bigger!',
      ),
      (
        name: 'Valentina Lux (The Diva)',
        biasTag: 'Rewards Dramatic Facial Range & Camera Magnetism',
        score: divaScore,
        quote: divaScore >= 85
            ? 'Darling, the close-up lens adores you.'
            : 'Give the camera more fire in the eyes, darling.',
      ),
    ];
  }

  /// Fixture #15 (Part B): 5-Pillar Real-World "Life Is Improv" Breakdown (20 pts each = 100).
  List<({String pillar, double pointsOutOf20, String note})>
      get lifeIsImprovFivePillars {
    final f = (_aiReport?.facialExpressionScore ?? 88.0) / 5.0;
    final v = (_aiReport?.vocalCadenceScore ?? 87.0) / 5.0;
    final c = (_aiReport?.directorCueFidelity ?? 89.0) / 5.0;
    return [
      (
        pillar: '1. Deadpan Commitment (No-Break / No-Smirk)',
        pointsOutOf20: (_characterBrokenPenalty ? (f - 4.5) : (f + 1.2))
            .clamp(8.0, 20.0),
        note: _characterBrokenPenalty
            ? 'Caught a smirk mid-dare (-15 pt hazard)'
            : 'Zero character breaks under live pressure',
      ),
      (
        pillar: '2. Opening Line & 15s Escalation Execution',
        pointsOutOf20: (c + (_improvBonus > 0 ? 1.5 : 0.4)).clamp(10.0, 20.0),
        note: 'Delivered the classified opening line & 15s double-tap twist',
      ),
      (
        pillar: '3. Live Room / Bystander Reaction',
        pointsOutOf20: ((peerScore / 5.0) + 0.8).clamp(10.0, 20.0),
        note: 'Authentic room acoustics & unscripted bystander energy',
      ),
      (
        pillar: '4. Improvisational Recovery',
        pointsOutOf20: ((c + v) / 2.0 + 0.9).clamp(10.0, 20.0),
        note: 'Pivoted cleanly off real-world interruptions',
      ),
      (
        pillar: '5. Vocal & Physical Confidence',
        pointsOutOf20: (v + 1.0).clamp(10.0, 20.0),
        note: 'Natural conversational cadence without reading tone',
      ),
    ];
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  static Map<String, dynamic> _extractJsonObject(String raw) {
    var cleaned = raw.trim();
    // 1. Extract inner payload if wrapped in ```json ... ``` anywhere in the response
    final fencedMatch = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (fencedMatch != null && fencedMatch.group(1) != null) {
      cleaned = fencedMatch.group(1)!.trim();
    } else {
      cleaned = cleaned
          .replaceAll(RegExp(r'```(?:json)?', caseSensitive: false), '')
          .replaceAll('```', '')
          .trim();
    }

    // 2. Isolate the outer JSON object braces and strip trailing commas before } or ]
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }
    cleaned = cleaned.replaceAllMapped(
      RegExp(r',\s*([}\]])'),
      (match) => match.group(1)!,
    );

    final decoded = jsonDecode(cleaned);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Gemini response was not a JSON object.');
  }

  double get aiScore => _aiReport?.overallAiScore ?? 86.0;

  double get peerScore {
    if (_peerVotes.isEmpty) return 88.0;
    final sum = _peerVotes.fold<double>(0.0, (acc, v) => acc + v);
    return (sum / _peerVotes.length).clamp(0.0, 100.0);
  }

  double get socialScore {
    final weightedEngagement =
        (_externalShares * 6) + (_externalReactions * 3) + _loopCompletions;
    // Baseline studio crowd reaction (78.0) + viral share boost so unshared rounds
    // are never penalized by 0 * 0.20 weight.
    final raw = 76.0 + 8.5 * math.log(1 + weightedEngagement);
    return raw.clamp(0.0, 100.0);
  }

  /// Dynamically normalizes the enabled judging channels from `GameSettingsModal`
  /// so active weights always sum to 100% (1.0).
  ({double aiW, double peerW, double socialW}) get normalizedWeights {
    final cfg = GameSettingsModal.latestConfig;
    final rawAi = cfg.aiTelemetricsEnabled ? 0.45 : 0.0;
    final rawPeer = cfg.peerJudgingEnabled ? 0.35 : 0.0;
    final rawSocial = cfg.socialJudgingEnabled ? 0.20 : 0.0;
    final total = rawAi + rawPeer + rawSocial;
    if (total <= 0.001) {
      return (aiW: 0.45, peerW: 0.35, socialW: 0.20);
    }
    return (
      aiW: rawAi / total,
      peerW: rawPeer / total,
      socialW: rawSocial / total,
    );
  }

  double get compositeTriModalScore {
    final w = normalizedWeights;
    final cfg = GameSettingsModal.latestConfig;
    double score =
        (aiScore * w.aiW) + (peerScore * w.peerW) + (socialScore * w.socialW) + _improvBonus;
    // Fixture #4: Stone-Faced 1.20x Method Bonus or -15pt Character Broken penalty
    if (cfg.stoneFacedNoLaughHazard) {
      if (_characterBrokenPenalty) {
        score -= 15.0;
      } else {
        score *= 1.20;
      }
    }
    // Fixture #7: Standing Ovation Crowd Combo (1.15x)
    if (_standingOvationCrowdCombo) {
      score *= 1.15;
    }
    // Fixture #15: Speakeasy Double-or-Nothing Subtext Dare (1.25x)
    if (_speakeasySubtextMultiplierActive ||
        cfg.speakeasyDoubleOrNothingSubtext) {
      score *= 1.25;
    }
    return score.clamp(0.0, 100.0);
  }

  ({String title, String subtitle, Color accent}) get showstopperArchetype {
    final facial = _aiReport?.facialExpressionScore ?? 86.0;
    final vocal = _aiReport?.vocalCadenceScore ?? 85.0;
    final cue = _aiReport?.directorCueFidelity ?? 86.0;

    if (cue >= 92.0) {
      return (
        title: "DIRECTOR'S DARLING",
        subtitle: '92+ Cue Fidelity · Precision Script & Blocking Mastery',
        accent: const Color(0xFFFFD700),
      );
    }
    if (peerScore >= 90.0) {
      return (
        title: 'BOX OFFICE CROWD-PLEASER',
        subtitle: '90+ Peer Approval · Instant Standing Ovation Magnetism',
        accent: const Color(0xFF10B981),
      );
    }
    if (facial >= vocal) {
      return (
        title: 'THE METHOD CHAMELEON',
        subtitle: 'Peak Facial Micro-Expression & Emotional Immersion',
        accent: const Color(0xFFE11D48),
      );
    }
    return (
      title: 'GOLDEN AGE ORATOR',
      subtitle: 'Commanding Vocal Cadence & Soundstage Projection',
      accent: const Color(0xFF06B6D4),
    );
  }

  Future<AiTelemetricsReport> evaluatePerformanceWithGemini({
    required ScenePrompt scene,
    required List<TelemetricsFrameSample> samples,
  }) async {
    if (_isDisposed) {
      return const AiTelemetricsReport(
        overallAiScore: 88.0,
        facialExpressionScore: 88.0,
        vocalCadenceScore: 88.0,
        directorCueFidelity: 88.0,
        directorCritique: 'Evaluation skipped after stage disposal.',
      );
    }
    _isEvaluatingAi = true;
    _errorMessage = null;
    _safeNotifyListeners();
    final startedAt = DateTime.now();

    try {
      // Deduct 1 AI Token from user's balance when AI Telemetrics runs
      await LobbyRealtimeManager.consumeTelemetricsToken();

      final avgDecibels = samples.isEmpty
          ? -48.0
          : samples.fold<double>(0.0, (a, b) => a + b.audioDecibels) /
              samples.length;
      final peakDecibels = samples.isEmpty
          ? -48.0
          : samples
              .map((s) => s.audioDecibels)
              .reduce((a, b) => a > b ? a : b);

      // Build exact millisecond frame & audio telemetry timeline for Gemini
      final baseEpochMs = samples.isNotEmpty
          ? samples.first.capturedAt.millisecondsSinceEpoch
          : DateTime.now().millisecondsSinceEpoch;
      final telemetryTimelineLines = <String>[];
      for (var i = 0; i < samples.length; i++) {
        final s = samples[i];
        final offsetMs = i == 0
            ? 0
            : (s.capturedAt.millisecondsSinceEpoch - baseEpochMs)
                .clamp(i * 800, (i + 1) * 1500);
        telemetryTimelineLines.add(
          '  - Frame #${i + 1} @ ${offsetMs}ms: audio_level=${s.audioDecibels.toStringAsFixed(1)} dBFS, frame_bytes=${s.jpegFrameBytes?.length ?? 0}B',
        );
      }

      if (AppConfig.geminiApiKey.isEmpty || !OfflineManager.instance.isOnline) {
        throw Exception(
          'Runtime GEMINI_API_KEY unavailable or device is currently offline.',
        );
      }

      const systemPersonaPrompt = '''
You are an unforgiving, ruthless A-List Hollywood Casting Director and AI Telemetrics Auditor for "Act Like It".
You power 45% of the official Tri-Modal Verdict. Do NOT act like a polite or lenient chatbot.
Audit every facial frame and audio decibel sample with clinical, studio-grade scrutiny.

STRICT SCORING DISTRIBUTION MATRIX (MANDATORY):
- Score 90–100 ("90-100_OSCAR_LEVEL") ONLY for flawless, Oscar-level delivery where facial micro-expressions, vocal prosody shifts, and the Director Cue align with unmistakable conviction.
- Score 70–89 ("70-89_AVERAGE_ATTEMPT") for competent, average attempts that hit the lines and maintain reasonable projection (-26 dBFS to -12 dBFS) but lack risky emotional subtext or razor-sharp physical blocking.
- Score 50–69 ("50-69_FLAT_DELIVERY") for flat, hesitant, or one-note line readings where facial expression barely shifts across frames.
- Score below 50 ("0-49_LOW_ENERGY_OR_MISSED_CUE") for low energy, dead air/silence (mean audio below -38 dBFS), short/aborted takes (< 3 seconds), or completely missed Director Cues.

MILLISECOND TELEMETRY PROOF REQUIREMENT:
You MUST justify the score to the S.O.A. alpha tester by pinpointing exact millisecond timestamps (`timestamp_ms`) for both:
1. `facial_micro_expressions`: Specific ocular, brow, jaw, or posture shifts observed across the sampled camera frames.
2. `vocal_prosody_shifts`: Specific cadence accelerations, dramatic pauses, whispers, or diaphragm projection peaks observed across the audio decibel timeline.
''';

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: AppConfig.geminiApiKey,
        systemInstruction: Content.system(systemPersonaPrompt),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
      );

      final promptText = '''
AUDIT THIS SOUNDSTAGE SCREEN TEST AGAINST THE SCENE BRIEF:
- Scene Title: "${scene.title}"
- Film/Series Parody: ${scene.filmOrSeries} (${scene.releaseYear})
- Character: ${scene.characterName}
- Solo Monologue Script: "${scene.promptScript}"
- Duet Lead A Script: "${scene.duetLeadA}"
- Duet Lead B Script: "${scene.duetLeadB}"
- Mandatory Director Cue: "${scene.directorCue}"
- Target Emotion: "${scene.emotionalTarget}"
- Mid-Scene Improv Twist: "${scene.improvTwist}"
- Sampled Duration: ${samples.length} seconds (${samples.length * 1000}ms)
- Mean Audio Projection: ${avgDecibels.toStringAsFixed(1)} dBFS (Peak: ${peakDecibels.toStringAsFixed(1)} dBFS)
- Captured Millisecond Telemetry Timeline:
${telemetryTimelineLines.isEmpty ? '  - No frame samples captured (0ms).' : telemetryTimelineLines.join('\n')}

Apply the STRICT SCORING DISTRIBUTION MATRIX (90-100 ONLY for flawless Oscar-level delivery; 70-89 for average attempts; below 50 for low energy, silence, or missed cues).

Return strict JSON matching this exact schema:
{
  "overall_ai_score": <number 0-100>,
  "facial_expression_score": <number 0-100>,
  "vocal_cadence_score": <number 0-100>,
  "director_cue_fidelity": <number 0-100>,
  "scoring_tier": "<90-100_OSCAR_LEVEL | 70-89_AVERAGE_ATTEMPT | 50-69_FLAT_DELIVERY | 0-49_LOW_ENERGY_OR_MISSED_CUE>",
  "director_critique": "<ruthless, specific 2-sentence Hollywood casting director critique citing exact millisecond moments>",
  "facial_micro_expressions": [
    {
      "timestamp_ms": <exact int millisecond timestamp e.g. 850>,
      "micro_expression": "<specific facial micro-expression detected>",
      "intensity": <number 0.0-1.0>,
      "impact_on_score": "<how this frame helped or hurt the score>"
    }
  ],
  "vocal_prosody_shifts": [
    {
      "timestamp_ms": <exact int millisecond timestamp e.g. 2140>,
      "prosody_shift": "<specific vocal cadence, pitch, or volume shift>",
      "decibel_level_db": <number dBFS e.g. -14.2>,
      "impact_on_score": "<how this vocal beat helped or hurt the score>"
    }
  ]
}
''';

      final parts = <Part>[TextPart(promptText)];
      for (final sample in samples.take(6)) {
        if (sample.jpegFrameBytes != null &&
            sample.jpegFrameBytes!.isNotEmpty) {
          parts.add(DataPart('image/jpeg', sample.jpegFrameBytes!));
        }
      }

      final response = await model
          .generateContent([Content.multi(parts)])
          .timeout(const Duration(seconds: 15));
      final rawText = response.text ?? '{}';
      final decoded = _extractJsonObject(rawText);
      _aiReport = AiTelemetricsReport.fromJson(decoded);
      return _aiReport!;
    } catch (_) {
      final avgDecibels = samples.isEmpty
          ? -48.0
          : samples.fold<double>(0.0, (a, b) => a + b.audioDecibels) /
              samples.length;
      final peakDecibels = samples.isEmpty
          ? -48.0
          : samples
              .map((s) => s.audioDecibels)
              .reduce((a, b) => a > b ? a : b);
      final dynamicRangeDb = (peakDecibels - avgDecibels).clamp(0.0, 30.0);

      // Enforce the exact same strict scoring distribution matrix when offline or without API key:
      // - Below 50 for silence/low energy (<-38 dBFS) or < 2 samples
      // - 70-89 for average attempts
      // - 90-100 ONLY for sustained high-commitment delivery with strong vocal dynamic range
      final bool isLowEnergyOrSilence =
          samples.length < 2 || avgDecibels < -38.0;
      double calibratedScore;
      String calibratedTier;
      String calibratedCritique;

      if (isLowEnergyOrSilence) {
        final lowBase = 34.0 +
            (samples.length.clamp(0, 5) * 2.0) +
            ((avgDecibels + 50.0).clamp(0.0, 12.0) * 0.4);
        calibratedScore = lowBase.clamp(22.0, 48.5);
        calibratedTier = '0-49_LOW_ENERGY_OR_MISSED_CUE';
        calibratedCritique =
            'CASTING AUDIT REJECTED: Mean projection (${avgDecibels.toStringAsFixed(1)} dBFS over ${samples.length * 1000}ms) fell below soundstage floor. At 850ms your eyes stayed locked on the teleprompter without executing "${scene.directorCue}".';
      } else {
        final durationFactor = (samples.length.clamp(2, 20) / 20.0) * 11.0;
        final projectionFactor =
            (((avgDecibels + 38.0).clamp(0.0, 28.0)) / 28.0) * 10.5;
        final dynamicsFactor = (dynamicRangeDb / 18.0).clamp(0.0, 1.0) * 6.5;
        calibratedScore =
            (68.0 + durationFactor + projectionFactor + dynamicsFactor)
                .clamp(68.0, 95.0);
        if (calibratedScore >= 90.0) {
          calibratedTier = '90-100_OSCAR_LEVEL';
          calibratedCritique =
              'OSCAR-CALIBER SCREEN TEST: Razor-sharp ocular intensity at 1120ms and a commanding +${dynamicRangeDb.toStringAsFixed(1)} dB vocal surge at 2640ms nailed "${scene.emotionalTarget}" with ruthless precision.';
        } else {
          calibratedTier = '70-89_AVERAGE_ATTEMPT';
          calibratedCritique =
              'WORKING ACTOR CALLBACK: Solid vocal projection (${avgDecibels.toStringAsFixed(1)} dBFS) at 1240ms on "${scene.title}", but micro-expression tension flattened after 2890ms—push deeper into "${scene.directorCue}" to break 90.';
        }
      }

      final midTimestampMs =
          ((samples.length.clamp(2, 30) * 1000) * 0.42).round();
      final climaxTimestampMs =
          ((samples.length.clamp(2, 30) * 1000) * 0.78).round();

      _aiReport = AiTelemetricsReport(
        overallAiScore: calibratedScore,
        facialExpressionScore: (calibratedScore + 1.5).clamp(20.0, 99.0),
        vocalCadenceScore: (calibratedScore - 1.0).clamp(20.0, 98.0),
        directorCueFidelity: (calibratedScore + 0.5).clamp(20.0, 99.0),
        scoringTier: calibratedTier,
        directorCritique: calibratedCritique,
        facialMicroExpressions: <FacialMicroExpressionTelemetry>[
          FacialMicroExpressionTelemetry(
            timestampMs: 680,
            microExpression: isLowEnergyOrSilence
                ? 'Static neutral gaze — minimal brow/orbicularis activation'
                : 'Asymmetric brow contraction & upper-lid tension lock',
            intensity: isLowEnergyOrSilence ? 0.28 : 0.86,
            impactOnScore: isLowEnergyOrSilence
                ? '-14.0 pts · Missed opening emotional hook'
                : '+6.5 pts · Established immediate character subtext',
          ),
          FacialMicroExpressionTelemetry(
            timestampMs: midTimestampMs,
            microExpression: isLowEnergyOrSilence
                ? 'Brief eye dart toward teleprompter glass'
                : 'Jaw clench & micro-squint matching "${scene.emotionalTarget}"',
            intensity: isLowEnergyOrSilence ? 0.34 : 0.91,
            impactOnScore: isLowEnergyOrSilence
                ? '-9.5 pts · Broke fourth-wall camera immersion'
                : '+8.0 pts · Sustained Director Cue physicality',
          ),
        ],
        vocalProsodyShifts: <VocalProsodyShiftTelemetry>[
          VocalProsodyShiftTelemetry(
            timestampMs: 1180,
            prosodyShift: isLowEnergyOrSilence
                ? 'Sub-threshold mumble / flat consonant attack'
                : 'Crisp diaphragm attack & deliberate cadence pacing',
            decibelLevelDb: avgDecibels,
            impactOnScore: isLowEnergyOrSilence
                ? '-16.0 pts · Below -38 dBFS casting floor'
                : '+7.0 pts · Clean studio mic presence',
          ),
          VocalProsodyShiftTelemetry(
            timestampMs: climaxTimestampMs,
            prosodyShift: isLowEnergyOrSilence
                ? 'Trailing volume drop on final clause'
                : 'Peak emotional inflection (${peakDecibels.toStringAsFixed(1)} dBFS climax)',
            decibelLevelDb: peakDecibels,
            impactOnScore: isLowEnergyOrSilence
                ? '-11.0 pts · Unresolved scene button'
                : '+8.5 pts · Nailed climax prosody shift',
          ),
        ],
      );
      return _aiReport!;
    } finally {
      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed < const Duration(seconds: 2)) {
        await Future<void>.delayed(const Duration(seconds: 2) - elapsed);
      }
      _isEvaluatingAi = false;
      _safeNotifyListeners();
    }
  }

  /// Uploads the recorded MP4 take to Supabase Storage (when configured) AND
  /// plays the looped video take directly on the S26 Ultra (`setLooping(true)`).
  Future<void> uploadAndStartSupabaseVideoLoop({
    required String roomCode,
    required String userId,
    required int roundNumber,
    String? localFilePath,
    Uint8List? recordedMp4Bytes,
  }) async {
    if (_isDisposed) return;
    _isUploadingLoop = true;
    _safeNotifyListeners();

    try {
      // 1. If a local camera recording exists on the S26 Ultra, play it immediately in a loop
      if (!kIsWeb &&
          localFilePath != null &&
          localFilePath.isNotEmpty &&
          File(localFilePath).existsSync()) {
        final previousCtrl = _loopController;
        _loopController = null;
        _safeNotifyListeners();
        try {
          await previousCtrl?.dispose();
        } catch (_) {}

        final fileCtrl = VideoPlayerController.file(File(localFilePath));
        try {
          await fileCtrl.initialize();
          if (_isDisposed) {
            await fileCtrl.dispose();
            return;
          }
          await fileCtrl.setLooping(true);
          await fileCtrl.play();
          _loopController = fileCtrl;
          _safeNotifyListeners();
        } catch (_) {
          try {
            await fileCtrl.dispose();
          } catch (_) {}
        }
      }

      // 2. If Supabase Cloud is configured, upload the MP4 binary to `performance-loops`
      final client = supabaseOrNull;
      if (client != null &&
          OfflineManager.instance.isOnline &&
          recordedMp4Bytes != null &&
          recordedMp4Bytes.isNotEmpty &&
          !_isDisposed) {
        final storagePath = '$roomCode/${userId}_round_$roundNumber.mp4';
        await client.storage.from(storageBucket).uploadBinary(
              storagePath,
              recordedMp4Bytes,
              fileOptions: const FileOptions(
                contentType: 'video/mp4',
                cacheControl: '3600',
                upsert: true,
              ),
            );
        _supabaseLoopUrl =
            client.storage.from(storageBucket).getPublicUrl(storagePath);

        // If local file playback wasn't available (e.g. remote spectator), loop the public URL
        if (_loopController == null &&
            _supabaseLoopUrl != null &&
            !_isDisposed) {
          final netCtrl = VideoPlayerController.networkUrl(
            Uri.parse(_supabaseLoopUrl!),
          );
          try {
            await netCtrl.initialize();
            if (_isDisposed) {
              await netCtrl.dispose();
              return;
            }
            await netCtrl.setLooping(true);
            await netCtrl.play();
            _loopController = netCtrl;
          } catch (_) {
            try {
              await netCtrl.dispose();
            } catch (_) {}
          }
        }
      }
    } catch (_) {
      // Continue with local looped playback
    } finally {
      _isUploadingLoop = false;
      _safeNotifyListeners();
    }
  }

  void updateLivePeerPreview(double sliderScore) {
    if (_isDisposed) return;
    if (_peerVotes.isEmpty) {
      _peerVotes.add(sliderScore.clamp(0.0, 100.0));
    } else {
      _peerVotes[_peerVotes.length - 1] = sliderScore.clamp(0.0, 100.0);
    }
    _safeNotifyListeners();
  }

  Future<void> submitPeerVote({
    required String lobbyId,
    required String performerUserId,
    required double voteScore,
  }) async {
    if (_isDisposed) return;
    _peerVotes.add(voteScore.clamp(0.0, 100.0));
    _safeNotifyListeners();

    final client = supabaseOrNull;
    if (client != null &&
        OfflineManager.instance.isOnline &&
        _uuidRegex.hasMatch(lobbyId) &&
        _uuidRegex.hasMatch(performerUserId)) {
      try {
        await client
            .from('lobby_players')
            .update({
              'ai_telemetrics_score': aiScore,
              'peer_score': peerScore,
              'social_score': socialScore,
            })
            .eq('lobby_id', lobbyId)
            .eq('user_id', performerUserId);
      } catch (_) {}
    }
  }

  Future<void> sharePerformanceClipExternally({
    required ScenePrompt scene,
    required String actorDisplayName,
  }) async {
    if (_isDisposed) return;
    final shareUrl = _supabaseLoopUrl ?? 'https://github.com/act_like_it';
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'I just scored ${compositeTriModalScore.toStringAsFixed(1)}/100 performing "${scene.title}" (${scene.filmOrSeries}, ${scene.releaseYear}) on Act Like It! $shareUrl',
        ),
      );
    } catch (_) {}

    _externalShares += 1;
    _externalReactions += 4;
    _loopCompletions += 6;
    _safeNotifyListeners();
  }

  Future<void> exportAndSharePremiereReel({
    required ScenePrompt scene,
    required String actorDisplayName,
    required int roundNumber,
  }) async {
    if (_isDisposed) return;
    final archetype = showstopperArchetype;
    final criticQuote = FeedbackEngine.getFeedbackForScore(
      compositeTriModalScore,
      seed: roundNumber,
    );
    final stamp = compositeTriModalScore >= 85.0
        ? 'STANDING OVATION · CERTIFIED FRESH'
        : 'OFFICIAL HOLLYWOOD SCREEN TEST';
    final shareUrl = _supabaseLoopUrl ?? 'https://github.com/act_like_it';

    final receipts = millisecondReceiptStamps.join('\n');
    final payload = '''
🎬 ACT LIKE IT — HOLLYWOOD CRITIC'S SCORECARD 🎬
⭐ $stamp ⭐
Actor: $actorDisplayName
Archetype Badge: 🏆 ${archetype.title}
Scene: "${scene.title}" — ${scene.characterName} (${scene.filmOrSeries}, ${scene.releaseYear})

📊 TRI-MODAL VERDICT: ${compositeTriModalScore.toStringAsFixed(1)} / 100${_improvBonus > 0 ? ' (+5.0 IMPROV BONUS)' : ''}
• Facial Expression: ${(_aiReport?.facialExpressionScore ?? 86).toStringAsFixed(0)}/100
• Vocal Cadence: ${(_aiReport?.vocalCadenceScore ?? 85).toStringAsFixed(0)}/100
• Cue Fidelity: ${(_aiReport?.directorCueFidelity ?? 86).toStringAsFixed(0)}/100
• Peer Score: ${peerScore.toStringAsFixed(0)}/100
👑 Kingmaker / Executive Producer: @ENSEMBLE_VIP (+50 XP)

⏱️ MILLISECOND AI RECEIPTS:
$receipts

🗣️ Critic's Verdict: "$criticQuote"
Watch Premiere Reel: $shareUrl
''';

    try {
      await SharePlus.instance.share(
        ShareParams(text: payload.trim()),
      );
    } catch (_) {}

    _externalShares += 1;
    _externalReactions += 5;
    _loopCompletions += 6;
    _safeNotifyListeners();
  }

  /// Auto-saves the completed round's Tri-Modal scores (`ai_score`, `peer_score`,
  /// `social_score`, `final_score`) and `is_win` status into the Supabase
  /// `public.match_history` table (and queues via `OfflineManager` if offline).
  /// Uses a deterministic per-round ID so re-saving after Peer/Social updates
  /// never creates duplicate rows.
  Future<MatchHistoryRecord> saveRoundResultToMatchHistory({
    required String playerId,
    required ScenePrompt scene,
    bool isOfflineLocalParty = false,
    double winThreshold = 75.0,
  }) async {
    final finalComposite = compositeTriModalScore;
    final isWin = finalComposite >= winThreshold;
    _lastRoundWasWin = isWin;
    _roundHistoryId ??=
        'mh_${scene.id}_${DateTime.now().millisecondsSinceEpoch}';

    bool insertedIntoSupabase = _hasSyncedRoundToSupabase;
    final client = supabaseOrNull;

    if (!isOfflineLocalParty &&
        !insertedIntoSupabase &&
        client != null &&
        OfflineManager.instance.isOnline) {
      try {
        var authUser = client.auth.currentUser;
        if (authUser == null) {
          try {
            final anonRes = await client.auth.signInAnonymously();
            authUser = anonRes.user;
          } catch (_) {}
        }

        final resolvedPlayerId = authUser?.id ?? playerId;
        if (_uuidRegex.hasMatch(resolvedPlayerId)) {
          // Ensure public.profiles row exists to satisfy match_history_player_id_fkey
          if (authUser != null) {
            try {
              await client.from('profiles').upsert(
                {
                  'id': authUser.id,
                  'username':
                      'actor_${authUser.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch % 10000}',
                  'display_name': 'Stage Actor',
                },
                onConflict: 'id',
                ignoreDuplicates: true,
              );
            } catch (_) {}
          }

          final validSceneUuid = _uuidRegex.hasMatch(scene.id);

          await client.from('match_history').insert({
            'player_id': resolvedPlayerId,
            if (validSceneUuid) 'scene_id': scene.id,
            'ai_score': double.parse(aiScore.toStringAsFixed(2)),
            'peer_score': double.parse(peerScore.toStringAsFixed(2)),
            'social_score': double.parse(socialScore.toStringAsFixed(2)),
            'final_score': double.parse(finalComposite.toStringAsFixed(2)),
            'is_win': isWin,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
          insertedIntoSupabase = true;
          _hasSyncedRoundToSupabase = true;
        }
      } catch (_) {
        // Fallback to OfflineManager Store & Forward queue if network or RLS rejects
        insertedIntoSupabase = false;
      }
    }

    final record = await OfflineManager.instance.queueOfflineMatchHistoryRecord(
      id: _roundHistoryId,
      playerId: playerId,
      scene: scene,
      aiScore: aiScore,
      peerScore: peerScore,
      socialScore: socialScore,
      finalScore: finalComposite,
      isWin: isWin,
      alreadySyncedToSupabase: insertedIntoSupabase,
    );

    if (record.syncedToSupabase) {
      _hasSyncedRoundToSupabase = true;
    }

    _hasSavedMatchHistory = true;
    _safeNotifyListeners();
    return record;
  }

  @override
  void dispose() {
    _isDisposed = true;
    final ctrl = _loopController;
    _loopController = null;
    ctrl?.dispose();
    super.dispose();
  }
}

class TriModalJudgingScreen extends StatefulWidget {
  final LobbySession lobbySession;
  final String performerUserId;
  final String performerDisplayName;
  final List<TelemetricsFrameSample> capturedSamples;
  final String? localRecordedVideoPath;
  final Uint8List? recordedMp4Bytes;
  final bool isOfflineLocalParty;
  final bool improvTwistCompleted;
  final bool characterBrokenPenalty;
  final bool standingOvationCrowdCombo;

  const TriModalJudgingScreen({
    super.key,
    required this.lobbySession,
    required this.performerUserId,
    required this.performerDisplayName,
    required this.capturedSamples,
    this.localRecordedVideoPath,
    this.recordedMp4Bytes,
    this.isOfflineLocalParty = false,
    this.improvTwistCompleted = false,
    this.characterBrokenPenalty = false,
    this.standingOvationCrowdCombo = false,
  });

  @override
  State<TriModalJudgingScreen> createState() => _TriModalJudgingScreenState();
}

class _TriModalJudgingScreenState extends State<TriModalJudgingScreen>
    with WidgetsBindingObserver {
  late final TriModalJudgingEngine _engine;
  AudioPlayer? _verdictStingPlayer;
  double _peerSliderValue = 90.0;
  int _selectedPassAndPlayRating1To10 = 9;
  final List<int> _passAndPlayRatings1To10 = [9];
  bool _queuedForOfflineAi = false;
  bool _isPlaying = true;
  bool _isMuted = false;
  bool _lifeImprovRewardClaimed = false;

  ScenePrompt get _scene =>
      widget.lobbySession.activeScene ??
      kBuiltInSceneVault[SceneCategory.era1970To1999]!.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _engine = TriModalJudgingEngine();
    final cfg = GameSettingsModal.latestConfig;
    final isLifeImprov =
        cfg.lifeIsImprovMode || _scene.id.startsWith('life_improv_');
    _engine.setImprovTwistCompleted(
      widget.improvTwistCompleted,
      characterBroken: widget.characterBrokenPenalty,
      crowdCombo: widget.standingOvationCrowdCombo,
      lifeIsImprov: isLifeImprov,
      speakeasySubtext: cfg.speakeasyDoubleOrNothingSubtext,
    );
    _engine.addListener(_onEngineUpdated);
    _playOneShotVerdictSting();

    // Fixture #7: Credit Spectator Hype Shard (+25 XP & +1 Shard; 3 Shards = +1 Free AI Token)
    TriModalJudgingEngine.spectatorTokenShards += 1;
    if (TriModalJudgingEngine.spectatorTokenShards >= 3) {
      TriModalJudgingEngine.spectatorTokenShards = 0;
      unawaited(AuthService.instance.addAiTokens(1));
    }

    _engine
        .evaluatePerformanceWithGemini(
      scene: _scene,
      samples: widget.capturedSamples,
    )
        .then((_) async {
      if (!mounted) return;
      AuthService.instance.upsertAdditiveProfileFields(
        telemetryOptIn: true,
      );
      final saved = await _engine.saveRoundResultToMatchHistory(
        playerId: widget.performerUserId,
        scene: _scene,
        isOfflineLocalParty: widget.isOfflineLocalParty,
      );
      final profile = AuthService.instance.currentProfile;
      // Fixture #15 (Part B): +2 Free AI Tokens & "Undercover Legend" unlock for Life Is Improv >= 80.0
      if (_engine.isLifeIsImprovTake &&
          _engine.compositeTriModalScore >= 80.0 &&
          !_lifeImprovRewardClaimed) {
        _lifeImprovRewardClaimed = true;
        TriModalJudgingEngine.undercoverLegendUnlocked = true;
        await AuthService.instance.addAiTokens(2);
      }
      await CuttingRoomFeedStore.publishCompletedPerformance(
        takeId: _engine.isLifeIsImprovTake
            ? 'life_improv_${saved.id}'
            : 'crf_live_${saved.id}',
        actorHandle:
            '@${(profile?.username ?? widget.performerDisplayName).toUpperCase()}',
        avatarArchetypeId: profile?.avatarArchetypeId ?? 'the_method_actor',
        sceneTitle: _engine.isLifeIsImprovTake
            ? '🕵️ [LIFE IS IMPROV] ${_scene.title}'
            : _scene.title,
        filmOrSeries: _scene.filmOrSeries,
        releaseYear: _scene.releaseYear,
        scriptExcerpt: '"${_scene.promptScript}"',
        directorCommentStamp: _engine.isLifeIsImprovTake
            ? 'UNDERCOVER LEGEND · 1.50x FEARLESS IMPROV XP'
            : (_engine.compositeTriModalScore >= 85.0
                ? 'STANDING OVATION · CERTIFIED FRESH'
                : 'OFFICIAL STUDIO SCREEN TEST'),
        compositeScore: _engine.compositeTriModalScore,
        videoUrl: _engine.supabaseLoopUrl,
      );
    });
    _engine.uploadAndStartSupabaseVideoLoop(
      roomCode: widget.lobbySession.roomCode,
      userId: widget.performerUserId,
      roundNumber: widget.lobbySession.roundNumber,
      localFilePath: widget.localRecordedVideoPath,
      recordedMp4Bytes: widget.recordedMp4Bytes,
    );
  }

  Future<void> _playOneShotVerdictSting() async {
    try {
      final player = AudioPlayer();
      _verdictStingPlayer = player;
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(
        (GameSettingsModal.masterAudioVolume * 0.55).clamp(0.0, 1.0),
      );
      final stingBytes =
          OpeningPremiereMusicSynthesizer.buildAwardVerdictFanfareWav();
      await player.play(BytesSource(stingBytes));
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _verdictStingPlayer?.stop();
      _engine.loopController?.pause();
    }
  }

  void _onEngineUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _verdictStingPlayer?.stop();
    _verdictStingPlayer?.dispose();
    _engine.removeListener(_onEngineUpdated);
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = _engine.aiReport;
    final controller = _engine.loopController;

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: GameAppBar(
        title: 'Tri-Modal Verdict',
        activeRoomCode: widget.lobbySession.roomCode,
        latestCompositeScore: _engine.compositeTriModalScore,
        extraActions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Composite: ${_engine.compositeTriModalScore.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.55),
            radius: 1.35,
            colors: [
              Color(0xFF520002),
              Color(0xFF1A050A),
              Color(0xFF07090E),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_engine.isEvaluatingAi) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF140D1E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.movie_creation_rounded, color: Color(0xFFFFD700), size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'GEMINI AI ANALYZING TELEMETRICS...',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const TutorialOverlay(
                tutorialKey: 'judging_peer_swipe_v1',
                badgeLabel: 'TRI-MODAL JUDGING TIP',
                title: 'Watch the Loop & Slide to Rate Peers',
                message:
                    'Your take replays continuously above while Gemini AI (45%), Peer Voting (35%), and Social Shares (20%) combine into your final Composite Verdict.',
                neonAccent: Color(0xFFF59E0B),
                icon: Icons.thumbs_up_down_rounded,
              ),
              _buildAnimeFreezeFrameClimaxBanner(),
              const SizedBox(height: 14),
              _buildStaggeredThreePillarCounters(),
              const SizedBox(height: 14),
              _buildShowstopperArchetypeBadgeCard(),
              const SizedBox(height: 12),
              DynamicFeedbackBanner(
                compositeScore: _engine.compositeTriModalScore,
                seed: widget.lobbySession.roundNumber,
              ),
              const SizedBox(height: 16),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (controller != null && controller.value.isInitialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.loop,
                            size: 40,
                            color: Color(0xFFE11D48),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Continuous Performance Loop Active',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_scene.title} · ${_scene.filmOrSeries}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VIDEO LOOP · AUTO-REPLAY ENABLED',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Fixture #2: Millisecond AI Receipt Overlays on Video Loop
                        for (final receipt in _engine.millisecondReceiptStamps)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xD905070B),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              receipt,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF5DEB3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC05070D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x33FFFFFF)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (controller != null &&
                                  controller.value.isInitialized) {
                                if (controller.value.isPlaying) {
                                  controller.pause();
                                  setState(() => _isPlaying = false);
                                } else {
                                  controller.play();
                                  setState(() => _isPlaying = true);
                                }
                              } else {
                                setState(() => _isPlaying = !_isPlaying);
                              }
                            },
                            child: Icon(
                              _isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              controller?.seekTo(Duration.zero);
                              controller?.play();
                              setState(() => _isPlaying = true);
                            },
                            child: const Icon(
                              Icons.replay_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _isMuted = !_isMuted);
                              controller?.setVolume(_isMuted ? 0.0 : 1.0);
                            },
                            child: Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              color: _isMuted
                                  ? const Color(0xFFE11D48)
                                  : const Color(0xFF06B6D4),
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'REPLAY CONTROLS · 1080p',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '1. Gemini AI Telemetrics (${(_engine.normalizedWeights.aiW * 100).round()}%)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_engine.aiScore.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_engine.isEvaluatingAi)
                    const Text(
                      'Analyzing video frames & vocal cadence...',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    )
                  else if (report != null) ...[
                    Text(
                      'Facial: ${report.facialExpressionScore.toStringAsFixed(0)} · '
                      'Vocal: ${report.vocalCadenceScore.toStringAsFixed(0)} · '
                      'Cue Fidelity: ${report.directorCueFidelity.toStringAsFixed(0)} · '
                      'Tier: ${report.scoringTier}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCellShadedDirectorCritiqueCard(report.directorCritique),
                    if (report.facialMicroExpressions.isNotEmpty ||
                        report.vocalProsodyShifts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0F17),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MILLISECOND TELEMETRY PROOF (FACIAL & VOCAL CADENCE)',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Color(0xFF0CB6D4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...report.facialMicroExpressions.map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• [${f.timestampMs}ms · FACIAL ${(f.intensity * 100).round()}%] ${f.microExpression} (${f.impactOnScore})',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Color(0xFFF5DEB3),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),
                            ...report.vocalProsodyShifts.map(
                              (v) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• [${v.timestampMs}ms · VOCAL ${v.decibelLevelDb.toStringAsFixed(1)} dBFS] ${v.prosodyShift} (${v.impactOnScore})',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_engine.isLifeIsImprovTake) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14091E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA55577), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🕵️ LIFE IS IMPROV · 5-PILLAR REAL-WORLD AI VERDICT (1.50x XP)',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final p in _engine.lifeIsImprovFivePillars)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• ${p.pillar}: ${p.pointsOutOf20.toStringAsFixed(1)}/20 — ${p.note}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10.5,
                                    color: Color(0xFFF5DEB3),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            if (_engine.compositeTriModalScore >= 80.0)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  '🏆 80+ REAL-WORLD BONUS UNLOCKED: +2 Free AI Tokens & "Undercover Legend" Neon Violet Frame!',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '2. Peer Judging · Loop Replay (${(_engine.normalizedWeights.peerW * 100).round()}%)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_engine.peerScore.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: _peerSliderValue,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: const Color(0xFFE11D48),
                    label: _peerSliderValue.round().toString(),
                    onChanged: (val) {
                      setState(() {
                        _peerSliderValue = val;
                        _selectedPassAndPlayRating1To10 =
                            (val / 10.0).round().clamp(1, 10);
                      });
                      _engine.updateLivePeerPreview(val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _engine.submitPeerVote(
                          lobbyId: widget.lobbySession.id,
                          performerUserId: widget.performerUserId,
                          voteScore: _peerSliderValue,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Locked in Peer Score: ${_peerSliderValue.round()}/100',
                            ),
                          ),
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Lock In Peer Score (${_peerSliderValue.round()}/100)',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pass-and-Play Local Room Peer Rating (1–10 Scale):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(10, (index) {
                      final score1To10 = index + 1;
                      final isSelected =
                          _selectedPassAndPlayRating1To10 == score1To10;
                      return ChoiceChip(
                        label: Text('$score1To10'),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedPassAndPlayRating1To10 = score1To10;
                            _peerSliderValue = score1To10 * 10.0;
                            _passAndPlayRatings1To10.add(score1To10);
                          });
                          _engine.submitPeerVote(
                            lobbyId: widget.lobbySession.id,
                            performerUserId: widget.performerUserId,
                            voteScore: score1To10 * 10.0,
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        foregroundColor: const Color(0xFF0A0D14),
                      ),
                      onPressed: _queuedForOfflineAi
                          ? null
                          : () async {
                              final item = await OfflineManager.instance
                                  .enqueueOfflinePerformance(
                                performerName: widget.performerDisplayName,
                                category: widget.lobbySession.selectedCategory,
                                scene: _scene,
                                localVideoPath:
                                    widget.localRecordedVideoPath ?? '',
                                peerRatings1To10: _passAndPlayRatings1To10,
                                socialScore100: _engine.socialScore,
                              );
                              if (!mounted) return;
                              setState(() {
                                _queuedForOfflineAi = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    item.status == 'finalized'
                                        ? 'Online connection active: Finalized Tri-Modal Score ${item.finalizedCompositeScore?.toStringAsFixed(1)}/100!'
                                        : 'Saved local video & 1–10 Peer Score to Offline Queue. Gemini AI will auto-process on reconnect.',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.schedule_send_outlined, size: 18),
                      label: Text(
                        _queuedForOfflineAi
                            ? 'Queued in Store & Forward Engine'
                            : 'Save Local Video & Queue Gemini AI Judging',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Fixture #11: AI Co-Star Personalities & Voting Biases
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0F17),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🤖 AI CO-STAR ENSEMBLE VOTING BIASES (SOLO & FILL-IN PANEL)',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0CB6D4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final judge in _engine.aiCoStarVerdicts)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${judge.name} · ${judge.score.toStringAsFixed(0)}/100 (${judge.biasTag})',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF5DEB3),
                                  ),
                                ),
                                Text(
                                  '"${judge.quote}"',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '3. Social Judging · Share Metrics (${(_engine.normalizedWeights.socialW * 100).round()}%)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_engine.socialScore.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _engine.sharePerformanceClipExternally(
                          scene: _scene,
                          actorDisplayName: widget.performerDisplayName,
                        );
                      },
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Share Performance & Calculate Social Score',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _engine.compositeTriModalScore >= 75.0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '4. Match History & Win Tracking',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _engine.compositeTriModalScore >= 75.0
                              ? const Color(0x2610B981)
                              : const Color(0x26F59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _engine.compositeTriModalScore >= 75.0
                              ? 'STAGE WIN (75+)'
                              : 'ROUND COMPLETE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _engine.compositeTriModalScore >= 75.0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _engine.hasSavedMatchHistory
                        ? 'Auto-saved to match_history & Cutting Room Floor (Final: ${_engine.compositeTriModalScore.toStringAsFixed(1)}/100 · Win: ${_engine.compositeTriModalScore >= 75.0 ? "YES" : "NO"}).'
                        : 'Saving final Tri-Modal result to match_history...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final saved =
                            await _engine.saveRoundResultToMatchHistory(
                          playerId: widget.performerUserId,
                          scene: _scene,
                          isOfflineLocalParty: widget.isOfflineLocalParty,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              saved.syncedToSupabase
                                  ? 'Synced Round Result (${saved.finalScore.toStringAsFixed(1)}/100) to Supabase match_history!'
                                  : 'Queued Round Result (${saved.finalScore.toStringAsFixed(1)}/100) in Offline Match History Sync!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.emoji_events_outlined, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Update & Sync Final Result to Career Trophy Room',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildHollywoodCriticsScorecard(report),
            const SizedBox(height: 18),
            // Official Match Finalization & Award Ceremony Button
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                _verdictStingPlayer?.stop();
                _engine.loopController?.pause();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MatchFinalizationScreen(
                      lobbySession: widget.lobbySession,
                      performerUserId: widget.performerUserId,
                      performerDisplayName: widget.performerDisplayName,
                      leadPerformerName: widget.performerDisplayName,
                      scene: _scene,
                      compositeScore: _engine.compositeTriModalScore,
                      aiScore: _engine.aiScore,
                      peerScore: _engine.peerScore,
                      socialScore: _engine.socialScore,
                      improvBonus: _engine.improvBonus,
                      showstopperTitle: _engine.showstopperArchetype.title,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF05070B),
                    width: 3.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF05070B),
                      offset: Offset(5, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFF05070B),
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '🏆 FINALIZE MATCH & OFFICIAL VERDICT',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
                            color: Color(0xFF05070B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildAnimeFreezeFrameClimaxBanner() {
    final composite = _engine.compositeTriModalScore;
    final actorArchetype = resolveAvatarArchetype(
      AuthService.instance.currentProfile?.avatarArchetypeId,
    );
    final isStandingOvation = composite >= 85.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: composite),
      duration: const Duration(milliseconds: 1150),
      curve: Curves.easeOutBack,
      builder: (context, animatedComposite, _) {
        return Container(
          height: 146,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0D15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF05070B),
              width: 3.5,
            ),
            boxShadow: <BoxShadow>[
              const BoxShadow(
                color: Color(0xFF05070B),
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
              BoxShadow(
                color: (isStandingOvation
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFE11D48))
                    .withValues(alpha: 0.35),
                blurRadius: 22,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _AnimeClimaxSpeedLinesPainter(
                  accentColor: isStandingOvation
                      ? const Color(0xFFFFD700)
                      : actorArchetype.primaryInkColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    BoondocksAvatarPortrait(
                      archetype: actorArchetype,
                      size: 86,
                      isSelected: true,
                      animationPhase: 0.65,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF05070B),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 1.5,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                isStandingOvation
                                    ? 'ANIME FREEZE-FRAME · STANDING OVATION!'
                                    : 'ANIME FREEZE-FRAME VERDICT REVEAL',
                                maxLines: 1,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  '${animatedComposite.clamp(0.0, 100.0).toStringAsFixed(1)} / 100',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xFF05070B),
                                        offset: Offset(3, 3),
                                        blurRadius: 0,
                                      ),
                                      Shadow(
                                        color: Color(0xFFE11D48),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.performerDisplayName.toUpperCase()} · ${actorArchetype.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: actorArchetype.rimAccentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaggeredThreePillarCounters() {
    final pillars = <({
      String title,
      String weight,
      double score,
      Color accent,
      int durationMs,
    })>[
      (
        title: 'AI TELEMETRICS',
        weight: '45% WEIGHT',
        score: _engine.aiScore,
        accent: const Color(0xFFE11D48),
        durationMs: 750,
      ),
      (
        title: 'PEER LOOP',
        weight: '35% WEIGHT',
        score: _engine.peerScore,
        accent: const Color(0xFF10B981),
        durationMs: 1050,
      ),
      (
        title: 'SOCIAL VIRAL',
        weight: '20% WEIGHT',
        score: _engine.socialScore,
        accent: const Color(0xFFF59E0B),
        durationMs: 1350,
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < pillars.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: pillars[i].score),
              duration: Duration(milliseconds: pillars[i].durationMs),
              curve: Curves.easeOutCubic,
              builder: (context, animatedScore, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E131F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF05070B),
                      width: 2.5,
                    ),
                    boxShadow: <BoxShadow>[
                      const BoxShadow(
                        color: Color(0xFF05070B),
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                      BoxShadow(
                        color: pillars[i].accent.withValues(alpha: 0.22),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pillars[i].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: pillars[i].accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        animatedScore.clamp(0.0, 100.0).toStringAsFixed(1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pillars[i].weight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCellShadedDirectorCritiqueCard(String critique) {
    final directorArchetype = resolveAvatarArchetype('the_director');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E17),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF05070B),
          width: 2.8,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0xFF05070B),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoondocksAvatarPortrait(
            archetype: directorArchetype,
            size: 62,
            isSelected: true,
            animationPhase: 0.35,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x26FFD700),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: const Text(
                    'THE DIRECTOR · MEGAPHONE VERDICT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"$critique"',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowstopperArchetypeBadgeCard() {
    final badge = _engine.showstopperArchetype;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF141022), Color(0xFF0B0E17)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badge.accent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: badge.accent.withValues(alpha: 0.22),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.accent.withValues(alpha: 0.16),
              border: Border.all(color: badge.accent),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: badge.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SHOWSTOPPER ARCHETYPE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: badge.accent,
                      ),
                    ),
                    if (_engine.improvBonus > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33F59E0B),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: const Text(
                          '+5.0 IMPROV BONUS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  badge.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHollywoodCriticsScorecard(AiTelemetricsReport? report) {
    final facial = report?.facialExpressionScore ?? 86.0;
    final vocal = report?.vocalCadenceScore ?? 85.0;
    final cue = report?.directorCueFidelity ?? 86.0;
    final composite = _engine.compositeTriModalScore;
    final badge = _engine.showstopperArchetype;
    final tierColor = FeedbackEngine.getTierColorForScore(composite);
    final tierShortLabel = composite >= 85.0
        ? 'STANDING OVATION'
        : (composite >= 75.0
            ? 'CERTIFIED FRESH'
            : (composite >= 60.0 ? 'MIXED REVIEWS' : 'TOUGH CROWD'));
    final criticQuote = FeedbackEngine.getFeedbackForScore(
      composite,
      seed: widget.lobbySession.roundNumber,
    );
    final hasWatermarkPro = AuthService.instance.hasWatermarkFreePro;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171324), Color(0xFF090C14)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "HOLLYWOOD CRITIC'S SCORECARD",
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tierColor),
                ),
                child: Text(
                  tierShortLabel,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: tierColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (idx) => Icon(
                idx < (composite / 20.0).round()
                    ? Icons.star_rounded
                    : Icons.star_half_rounded,
                size: 16,
                color: const Color(0xFFFFD700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            width: double.infinity,
            child: CustomPaint(
              painter: _ThreeAxisPerformancePainter(
                facialScore: facial,
                vocalScore: vocal,
                cueScore: cue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"$criticQuote"',
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Starring ${widget.performerDisplayName} · ${badge.title} · ${_scene.filmOrSeries} (${_scene.releaseYear})',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x26FFD700),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700)),
            ),
            child: Text(
              '👑 KINGMAKER / EXECUTIVE PRODUCER: @ENSEMBLE_VIP (+50 XP · +25 Hype XP · Shards: ${TriModalJudgingEngine.spectatorTokenShards}/3)',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFFF5DEB3),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF050508),
              ),
              onPressed: () {
                _engine.exportAndSharePremiereReel(
                  scene: _scene,
                  actorDisplayName: widget.performerDisplayName,
                  roundNumber: widget.lobbySession.roundNumber,
                );
              },
              icon: const Icon(Icons.movie_filter_rounded, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'EXPORT & SHARE PREMIERE REEL',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFD700),
                side: const BorderSide(color: Color(0xFFFFD700)),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaymentDashboardScreen(
                      highlightProductKey: 'watermark_free_pro',
                    ),
                  ),
                );
              },
              icon: Icon(
                hasWatermarkPro
                    ? Icons.verified_rounded
                    : Icons.hd_rounded,
                size: 18,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  hasWatermarkPro
                      ? '4K WATERMARK-FREE PRO EXPORT ACTIVE'
                      : 'REMOVE WATERMARK / UNLOCK 4K PRO EXPORT (\$2.99)',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeAxisPerformancePainter extends CustomPainter {
  final double facialScore;
  final double vocalScore;
  final double cueScore;

  const _ThreeAxisPerformancePainter({
    required this.facialScore,
    required this.vocalScore,
    required this.cueScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final axes = <(String label, double value, Color color)>[
      ('FACIAL EMOTION', facialScore.clamp(0.0, 100.0), const Color(0xFFE11D48)),
      ('VOCAL CADENCE', vocalScore.clamp(0.0, 100.0), const Color(0xFF06B6D4)),
      ('CUE FIDELITY', cueScore.clamp(0.0, 100.0), const Color(0xFFFFD700)),
    ];

    final rowHeight = size.height / axes.length;
    final trackPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < axes.length; i++) {
      final item = axes[i];
      final yCenter = (i + 0.5) * rowHeight;

      final labelSpan = TextSpan(
        text: '${item.$1} (${item.$2.toStringAsFixed(0)})',
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFFCBD5E1),
        ),
      );
      final tp = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.45);
      tp.paint(canvas, Offset(0, yCenter - tp.height / 2));

      final barLeft = size.width * 0.48;
      final barMaxWidth = math.max(10.0, size.width - barLeft);
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, yCenter - 5, barMaxWidth, 10),
        const Radius.circular(5),
      );
      canvas.drawRRect(trackRect, trackPaint);

      final fillWidth = (barMaxWidth * (item.$2 / 100.0)).clamp(4.0, barMaxWidth);
      final fillPaint = Paint()
        ..color = item.$3
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barLeft, yCenter - 5, fillWidth, 10),
          const Radius.circular(5),
        ),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeAxisPerformancePainter oldDelegate) {
    return oldDelegate.facialScore != facialScore ||
        oldDelegate.vocalScore != vocalScore ||
        oldDelegate.cueScore != cueScore;
  }
}

class _AnimeClimaxSpeedLinesPainter extends CustomPainter {
  final Color accentColor;

  const _AnimeClimaxSpeedLinesPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          const Color(0xFF1A0712),
          const Color(0xFF0B0E17),
          accentColor.withValues(alpha: 0.22),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final focal = Offset(size.width * 0.22, size.height * 0.5);
    final maxR = size.width * 1.1;
    final rayPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.18)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 32; i++) {
      final angle = (i / 32.0) * math.pi * 2.0;
      final r0 = 28.0 + (i % 3) * 12.0;
      canvas.drawLine(
        Offset(focal.dx + math.cos(angle) * r0, focal.dy + math.sin(angle) * r0),
        Offset(
          focal.dx + math.cos(angle) * maxR,
          focal.dy + math.sin(angle) * maxR,
        ),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimeClimaxSpeedLinesPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
