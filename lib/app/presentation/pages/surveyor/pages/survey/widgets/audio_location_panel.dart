import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../core/values/app_colors.dart';
import '../../../../../../../core/services/audio_service.dart';

class AudioLocationPanel extends StatefulWidget {
  final bool showLocation;
  final bool showAudioRecorder;

  const AudioLocationPanel({
    super.key,
    required this.showLocation,
    required this.showAudioRecorder,
  });

  @override
  State<AudioLocationPanel> createState() => _AudioLocationPanelState();
}

class _AudioLocationPanelState extends State<AudioLocationPanel> {
  bool isRecording = false;

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showLocation && !widget.showAudioRecorder) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (widget.showLocation)
            if (widget.showAudioRecorder)
              Container(
                margin: const EdgeInsets.only(bottom: 8, right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.successBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.successBorder,
                ),
              )
            else
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.successBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.successBorder,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Esta encuesta usa geolocalización",
                          style: TextStyle(color: AppColors.successBorder),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (widget.showAudioRecorder)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Obx(() {
                        final audioService = Get.find<AudioService>();

                        return audioService.isRecording.value
                            ? const Icon(Icons.mic, color: Colors.red)
                            : const Icon(Icons.mic_none, color: Colors.grey);
                      }),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 32,
                              color: Colors.red.withOpacity(0.1),
                              child: Center(
                                child: Obx(() {
                                  final audioService = Get.find<AudioService>();
                                  return CustomPaint(
                                    size: const Size(100, 32),
                                    painter: WavePainter(audioService.amplitude.value),
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            final audioService = Get.find<AudioService>();
                            return Text(
                              _formatDuration(audioService.recordingDuration.value),
                              style: const TextStyle(fontSize: 16),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedWave extends StatefulWidget {
  const AnimatedWave({super.key});

  @override
  AnimatedWaveState createState() => AnimatedWaveState();
}

class AnimatedWaveState extends State<AnimatedWave>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _amplitudeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Creando una animación que va de 0 a 1 para simular el cambio en amplitud
    _amplitudeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Iniciar la animación de amplitud
    _animationController.repeat(
        reverse:
            true); // Repite la animación (puedes cambiar esto según el caso)
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final audioService = Get.find<AudioService>();
      audioService.amplitude.value = _amplitudeAnimation.value;

      return CustomPaint(
        size: const Size(100, 32),
        painter: WavePainter(audioService.amplitude.value),
      );
    });
  }
}

class WavePainter extends CustomPainter {
  final double amplitude;

  WavePainter(this.amplitude);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path path = Path();
    double midY = size.height / 2;
    path.moveTo(0, midY);

    // Dibujar una onda simple basada en la amplitud
    for (double x = 0; x < size.width; x++) {
      double y = midY + amplitude * 20 * (x / size.width);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
