import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Synthesizes a real 16-bit PCM WAV Hollywood Premiere Opening Soundtrack and
/// 1.5-second Award Verdict Fanfare Sting in memory with zero low-frequency buzzy drone.
class OpeningPremiereMusicSynthesizer {
  static Uint8List? _cachedWavBytes;
  static Uint8List? _cachedVerdictStingBytes;

  /// Short, crisp 1.5-second Hollywood Award Fanfare Sting for the Verdict Screen.
  /// Plays once and decays cleanly to silence (zero continuous loop or bass buzz).
  static Uint8List buildAwardVerdictFanfareWav() {
    if (_cachedVerdictStingBytes != null) return _cachedVerdictStingBytes!;

    const int sampleRate = 22050;
    const int numSamples = 33075; // 1.5 seconds
    final int dataSize = numSamples * 2;
    final ByteData buffer = ByteData(44 + dataSize);

    void writeAscii(int offset, String text) {
      for (int i = 0; i < text.length; i++) {
        buffer.setUint8(offset + i, text.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    buffer.setUint32(4, 36 + dataSize, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little);
    buffer.setUint16(22, 1, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little);
    buffer.setUint16(32, 2, Endian.little);
    buffer.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    buffer.setUint32(40, dataSize, Endian.little);

    // Bright C-Major 9th fanfare arpeggio -> warm golden chord chime with exponential decay
    const List<double> notes = <double>[523.25, 659.25, 783.99, 1046.50];
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      double sample = 0.0;

      for (int n = 0; n < notes.length; n++) {
        final double noteStart = n * 0.09;
        if (t >= noteStart) {
          final double localT = t - noteStart;
          final double env =
              (1.0 - math.exp(-localT * 45.0)) * math.exp(-localT * 2.6);
          final double freq = notes[n];
          sample += (math.sin(2.0 * math.pi * freq * localT) * 0.20 +
                  math.sin(2.0 * math.pi * (freq * 1.5) * localT) * 0.05) *
              env;
        }
      }

      final double tailFade =
          t > 1.15 ? ((1.5 - t) / 0.35).clamp(0.0, 1.0) : 1.0;
      final int pcm16 =
          ((sample * tailFade).clamp(-0.85, 0.85) * 32767.0).round();
      buffer.setInt16(44 + i * 2, pcm16, Endian.little);
    }

    _cachedVerdictStingBytes = buffer.buffer.asUint8List();
    return _cachedVerdictStingBytes!;
  }

  static Uint8List buildOpeningFanfareWav() {
    if (_cachedWavBytes != null) return _cachedWavBytes!;

    const int sampleRate = 22050;
    const int durationSeconds = 6;
    const int numSamples = sampleRate * durationSeconds;
    final int dataSize = numSamples * 2; // 16-bit mono PCM
    final ByteData buffer = ByteData(44 + dataSize);

    void writeAscii(int offset, String text) {
      for (int i = 0; i < text.length; i++) {
        buffer.setUint8(offset + i, text.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    buffer.setUint32(4, 36 + dataSize, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little);
    buffer.setUint16(22, 1, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little);
    buffer.setUint16(32, 2, Endian.little);
    buffer.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    buffer.setUint32(40, dataSize, Endian.little);

    final math.Random rng = math.Random(42);

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      double sample = 0.0;

      if (t < 1.35) {
        final double swellProgress = (t / 1.35).clamp(0.0, 1.0);
        final double freq1 = 261.63 + swellProgress * 68.0;
        final double freq2 = 392.00 + swellProgress * 131.25;
        sample = (math.sin(2.0 * math.pi * freq1 * t) * 0.22 +
                math.sin(2.0 * math.pi * freq2 * t) * 0.16) *
            swellProgress *
            math.exp(-t * 0.3);
      } else {
        if (t >= 1.35 && t < 1.52) {
          final double snapEnv = math.exp(-(t - 1.35) * 38.0);
          final double noise = (rng.nextDouble() * 2.0 - 1.0) * 0.38 * snapEnv;
          final double woodClick =
              math.sin(2.0 * math.pi * 880.0 * t) * 0.30 * snapEnv;
          sample += noise + woodClick;
        }

        // Clean mid-high orchestral chime chords with natural exponential decay (no low bass drone)
        const List<double> chordNotes = <double>[
          261.63,
          329.63,
          392.00,
          523.25,
          659.25,
        ];
        final double chordTime = t - 1.35;
        final double chordEnv = math.exp(-chordTime * 0.85);
        double chordSum = 0.0;
        for (int n = 0; n < chordNotes.length; n++) {
          final double f = chordNotes[n];
          chordSum += math.sin(2.0 * math.pi * f * t) * 0.10;
        }

        final double loopFade =
            t > 4.8 ? ((6.0 - t) / 1.2).clamp(0.0, 1.0) : 1.0;
        sample += chordSum * chordEnv * loopFade;
      }

      final int pcm16 = (sample.clamp(-0.85, 0.85) * 32767.0).round();
      buffer.setInt16(44 + i * 2, pcm16, Endian.little);
    }

    _cachedWavBytes = buffer.buffer.asUint8List();
    return _cachedWavBytes!;
  }
}

/// Central interactive brand centerpiece & Opening Sequence Hero featuring the
/// **Golden Cyber-Mask Maestro** from the official "ACT LIKE IT" opening video.
class ActLikeItBrandCenterpiece extends StatefulWidget {
  final double height;
  final bool compact;
  final VoidCallback? onTap;

  const ActLikeItBrandCenterpiece({
    super.key,
    this.height = 236,
    this.compact = false,
    this.onTap,
  });

  @override
  State<ActLikeItBrandCenterpiece> createState() =>
      _ActLikeItBrandCenterpieceState();
}

class _ActLikeItBrandCenterpieceState extends State<ActLikeItBrandCenterpiece>
    with SingleTickerProviderStateMixin {
  late final AnimationController _openingLoopController;
  Offset _tiltOffset = Offset.zero;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _openingLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _openingLoopController.dispose();
    super.dispose();
  }

  void _updateTilt(Offset localPos, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final dx = ((localPos.dx / size.width) - 0.5) * 2.0;
    final dy = ((localPos.dy / size.height) - 0.5) * 2.0;
    setState(() {
      _tiltOffset = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 340,
          widget.height,
        );
        return GestureDetector(
          onTapDown: (d) {
            HapticFeedback.lightImpact();
            setState(() => _isPressed = true);
            _updateTilt(d.localPosition, boxSize);
          },
          onPanUpdate: (d) => _updateTilt(d.localPosition, boxSize),
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
              _tiltOffset = Offset.zero;
            });
            widget.onTap?.call();
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
              _tiltOffset = Offset.zero;
            });
          },
          child: AnimatedBuilder(
            animation: _openingLoopController,
            builder: (context, _) {
              final sec = _openingLoopController.value * 8.0;
              final matrix = Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(-_tiltOffset.dy * 0.14)
                ..rotateY(_tiltOffset.dx * 0.16)
                ..scale(_isPressed ? 0.97 : 1.0);

              return Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07090E),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF05070B),
                      width: 3.8,
                    ),
                    boxShadow: <BoxShadow>[
                      const BoxShadow(
                        color: Color(0xFF05070B),
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFB300).withValues(
                          alpha: 0.32 + 0.18 * math.sin(sec * 2.2),
                        ),
                        blurRadius: 26,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _OpeningCyberMaskMaestroPainter(
                            seconds: sec,
                            compact: widget.compact,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xD907090E),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF00E5FF),
                                width: 1.4,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: (sec * 2).floor().isEven
                                        ? const Color(0xFFFF1744)
                                        : const Color(0x55FF1744),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'REC 00:0${sec.floor()} · CYBER-MASK OPENING',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF84FFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: widget.compact ? 6 : 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'ACT LIKE IT',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: widget.compact ? 36 : 48,
                                    letterSpacing: 3.2,
                                    height: 0.92,
                                    color: const Color(0xFFFFE082),
                                    shadows: const <Shadow>[
                                      Shadow(
                                        color: Color(0xFF05070B),
                                        offset: Offset(4, 4),
                                        blurRadius: 0,
                                      ),
                                      Shadow(
                                        color: Color(0xFFFF8F00),
                                        offset: Offset(2, 2),
                                        blurRadius: 0,
                                      ),
                                      Shadow(
                                        color: Color(0xFFFFD600),
                                        offset: Offset(0, 0),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!widget.compact)
                                const Text(
                                  'TAP MAESTRO CLAPPERBOARD TO ROLL CAMERA',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: Color(0xFFF5DEB3),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OpeningCyberMaskMaestroPainter extends CustomPainter {
  final double seconds;
  final bool compact;

  const _OpeningCyberMaskMaestroPainter({
    required this.seconds,
    required this.compact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.44;
    final s = size.shortestSide;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF05070B),
            Color(0xFF140D04),
            Color(0xFF07090E),
          ],
        ).createShader(Offset.zero & size),
    );

    final beamSwing1 = math.sin(seconds * 1.1) * (w * 0.18);
    final beamSwing2 = math.cos(seconds * 0.9) * (w * 0.18);
    final beamPaint = Paint()
      ..color = const Color(0xFFFFB300).withValues(alpha: 0.22);

    final leftBeam = Path()
      ..moveTo(w * 0.18, h)
      ..lineTo(cx + beamSwing1 - w * 0.18, 0)
      ..lineTo(cx + beamSwing1 + w * 0.10, 0)
      ..close();
    final rightBeam = Path()
      ..moveTo(w * 0.82, h)
      ..lineTo(cx + beamSwing2 - w * 0.10, 0)
      ..lineTo(cx + beamSwing2 + w * 0.18, 0)
      ..close();
    canvas.drawPath(leftBeam, beamPaint);
    canvas.drawPath(rightBeam, beamPaint);

    final ribbonY = cy + math.sin(seconds * 1.6) * (h * 0.04);
    final ribbonPath = Path()
      ..moveTo(-10, ribbonY + h * 0.16)
      ..cubicTo(
        w * 0.25,
        ribbonY - h * 0.22,
        w * 0.75,
        ribbonY + h * 0.26,
        w + 10,
        ribbonY - h * 0.12,
      );
    canvas.drawPath(
      ribbonPath,
      Paint()
        ..color = const Color(0xFFFFD600)
        ..strokeWidth = s * 0.145
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      ribbonPath,
      Paint()
        ..color = const Color(0xFFC62828)
        ..strokeWidth = s * 0.115
        ..style = PaintingStyle.stroke,
    );

    final breath = math.sin(seconds * 2.4) * (s * 0.015);
    final torsoTop = cy - s * 0.02 + breath;
    final tuxPath = Path()
      ..moveTo(cx - s * 0.44, h)
      ..lineTo(cx - s * 0.34, torsoTop)
      ..lineTo(cx + s * 0.34, torsoTop)
      ..lineTo(cx + s * 0.44, h)
      ..close();
    canvas.drawPath(tuxPath, Paint()..color = const Color(0xFF880E4F));
    canvas.drawPath(
      tuxPath,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke,
    );

    final shirtPath = Path()
      ..moveTo(cx - s * 0.10, torsoTop)
      ..lineTo(cx + s * 0.10, torsoTop)
      ..lineTo(cx, torsoTop + s * 0.24)
      ..close();
    canvas.drawPath(shirtPath, Paint()..color = const Color(0xFFFFF8E1));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, torsoTop + s * 0.05),
          width: s * 0.14,
          height: s * 0.055,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFD50000),
    );

    final headCenter = Offset(cx - s * 0.02, cy - s * 0.20 + breath);
    final headR = s * 0.19;

    final tragedyCenter = Offset(
      headCenter.dx + headR * 0.85 + math.sin(seconds * 3.0) * 2.5,
      headCenter.dy + headR * 0.06,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: tragedyCenter,
        width: headR * 1.05,
        height: headR * 1.45,
      ),
      Paint()..color = const Color(0xFFFFB300),
    );
    canvas.drawCircle(
      Offset(tragedyCenter.dx + headR * 0.14, tragedyCenter.dy - headR * 0.12),
      headR * 0.11,
      Paint()..color = const Color(0xFFFF1744),
    );

    final mainHeadRect = Rect.fromCenter(
      center: headCenter,
      width: headR * 1.55,
      height: headR * 1.75,
    );
    canvas.drawOval(
      mainHeadRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFFE082),
            Color(0xFFFFB300),
            Color(0xFFFF6F00),
          ],
        ).createShader(mainHeadRect),
    );
    canvas.drawOval(
      mainHeadRect,
      Paint()
        ..color = const Color(0xFF05070B)
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke,
    );

    final lensCenter =
        Offset(headCenter.dx + headR * 0.26, headCenter.dy - headR * 0.08);
    canvas.drawCircle(
      lensCenter,
      headR * 0.42,
      Paint()..color = const Color(0xFF263238),
    );
    canvas.drawCircle(
      lensCenter,
      headR * 0.30,
      Paint()..color = const Color(0xFF00E5FF),
    );
    canvas.drawCircle(
      lensCenter,
      headR * 0.14,
      Paint()..color = const Color(0xFF05070B),
    );
    canvas.drawCircle(
      Offset(lensCenter.dx - headR * 0.08, lensCenter.dy - headR * 0.08),
      headR * 0.06,
      Paint()..color = Colors.white,
    );

    final slateCenter = Offset(cx - s * 0.10, cy + s * 0.15 + breath);
    final slateW = s * 0.46;
    final slateH = s * 0.32;
    final slateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: slateCenter, width: slateW, height: slateH),
      const Radius.circular(6),
    );
    canvas.drawRRect(slateRect, Paint()..color = const Color(0xFF0B0E17));
    canvas.drawRRect(
      slateRect,
      Paint()
        ..color = const Color(0xFFFFD600)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    final bool isSnapped = seconds >= 1.1 && seconds <= 3.4;
    final double jawAngle = isSnapped ? 0.0 : -0.34;
    canvas.save();
    canvas.translate(slateRect.left, slateRect.top);
    canvas.rotate(jawAngle);
    final barRect = Rect.fromLTWH(0, -s * 0.065, slateW, s * 0.065);
    canvas.drawRect(barRect, Paint()..color = const Color(0xFF0B0E17));
    for (double x = 4; x < slateW - 8; x += s * 0.09) {
      final stripe = Path()
        ..moveTo(x, -s * 0.065)
        ..lineTo(x + s * 0.045, -s * 0.065)
        ..lineTo(x + s * 0.02, 0)
        ..lineTo(x - s * 0.025, 0)
        ..close();
      canvas.drawPath(stripe, Paint()..color = const Color(0xFFFFD600));
    }
    canvas.restore();

    double flashIntensity = 0.0;
    if (seconds >= 1.0 && seconds <= 3.6) {
      flashIntensity = math.sin(((seconds - 1.0) / 2.6) * math.pi);
    } else {
      flashIntensity = 0.25 + 0.15 * math.sin(seconds * 3.0);
    }

    final flareOrigin =
        Offset(slateRect.center.dx + slateW * 0.12, slateRect.top);
    final flareR = s * (0.18 + 0.36 * flashIntensity);
    canvas.drawCircle(
      flareOrigin,
      flareR,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: (0.95 * flashIntensity).clamp(0.0, 1.0)),
            const Color(0xFFFFD600)
                .withValues(alpha: (0.72 * flashIntensity).clamp(0.0, 1.0)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: flareOrigin, radius: flareR)),
    );
  }

  @override
  bool shouldRepaint(covariant _OpeningCyberMaskMaestroPainter oldDelegate) {
    return oldDelegate.seconds != seconds || oldDelegate.compact != compact;
  }
}
