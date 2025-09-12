import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../../core/services/audio_service.dart';

class AudioLocationPanel extends StatelessWidget {
  final bool showLocation;
  final bool showAudioRecorder;

  const AudioLocationPanel({
    super.key,
    required this.showLocation,
    required this.showAudioRecorder,
  });

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    if (!showLocation && !showAudioRecorder) return const SizedBox.shrink();

    // 3 combinaciones posibles:
    if (showLocation && showAudioRecorder) {
      // Ubicación compacta + audio expandido
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const _LocationBadge(expanded: false),
            const SizedBox(width: 8),
            Expanded(child: _RecorderPill(scheme: scheme, fmt: _fmt)),
          ],
        ),
      );
    } else if (showLocation && !showAudioRecorder) {
      // Solo ubicación -> expandida
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _LocationBadge(expanded: true)),
          ],
        ),
      );
    } else {
      // Solo audio -> expandido
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _RecorderPill(scheme: scheme, fmt: _fmt)),
          ],
        ),
      );
    }
  }
}

class _LocationBadge extends StatelessWidget {
  final bool expanded; // true = ícono + texto (se expande), false = solo ícono (compacto)

  const _LocationBadge({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final bg = AppColorScheme.successBackground.withOpacity(0.15);

    final box = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFF31E981).withOpacity(0.1),
        border: Border.all( color: Color(0xFF31E981)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 20,
            color: Color(0xFF31E981),
          ),
          if (expanded) ...[
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Esta encuesta usa geolocalización",
                style: TextStyle(
                  color: AppColorScheme.successText,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    // Si expanded es true, el padre ya envuelve con Expanded. Aquí devolvemos tal cual.
    // Si es compacta, tampoco necesitamos Expanded aquí.
    return box;
  }
}

class _RecorderPill extends StatelessWidget {
  final AppColorScheme scheme;
  final String Function(int) fmt;

  const _RecorderPill({required this.scheme, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioService>();

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.secondBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // mic en círculo blanco
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Obx(() {
              return Icon(
                audio.isRecording.value ? Icons.mic : Icons.mic_none,
                size: 18,
                color: audio.isRecording.value ? Colors.red : Colors.grey[500],
              );
            }),
          ),
          const SizedBox(width: 10),

          // Onda
          Expanded(
            child: SizedBox(
              height: 26,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  alignment: Alignment.center,
                  child: Obx(() {
                    return CustomPaint(
                      size: const Size(double.infinity as double, 22),
                      painter: _BarsWavePainter(amplitude: audio.amplitude.value),
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Tiempo
          Obx(() => Text(
            fmt(audio.recordingDuration.value),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          )),
        ],
      ),
    );
  }
}

/// Onda con barras rojas (tipo ecualizador)
class _BarsWavePainter extends CustomPainter {
  final double amplitude; // valor 0..1 proveniente del AudioService

  _BarsWavePainter({required this.amplitude});

  @override
  void paint(Canvas canvas, Size size) {
    const int bars = 24;
    const double gap = 3;
    final double w = (size.width - (bars - 1) * gap) / bars;
    final double mid = size.height / 2;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE11D48), Color(0xFFB91C1C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < bars; i++) {
      final t = i / (bars - 1);
      final base = 0.3 + 0.7 * (0.5 - (t - 0.5).abs() * 1.2);
      final h = (base * amplitude).clamp(0.08, 1.0) * mid;

      final left = i * (w + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, mid - h, w, 2 * h),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }

    // Línea roja vertical (cursor) opcional
    final cursorX = size.width * 0.72;
    final cursorPaint = Paint()
      ..color = const Color(0xFFE11D48).withOpacity(0.9)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cursorX, 0), Offset(cursorX, size.height), cursorPaint);
  }

  @override
  bool shouldRepaint(covariant _BarsWavePainter oldDelegate) =>
      oldDelegate.amplitude != amplitude;
}
