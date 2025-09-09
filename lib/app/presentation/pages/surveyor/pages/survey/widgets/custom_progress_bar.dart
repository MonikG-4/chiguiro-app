import 'package:flutter/material.dart';

import '../../../../../../../core/theme/app_colors_theme.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress;
  final double height;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).clamp(0, 100).toInt();
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final progressWidth = constraints.maxWidth * progress;
        final bool isTextInside = progressWidth > 52;

        return Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: scheme.secondBackground,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),

            Container(
              height: height,
              width: progressWidth,
              decoration: BoxDecoration(
                color: AppColorScheme.primary,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            Positioned(
              left: progressWidth - (isTextInside ? 48 : -12),
              top: 0,
              bottom: 0,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    color: isTextInside ? Colors.white : scheme.onFirstBackground,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
