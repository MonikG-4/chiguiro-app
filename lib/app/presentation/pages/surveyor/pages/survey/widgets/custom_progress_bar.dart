import 'package:flutter/material.dart';

import '../../../../../../../core/values/app_colors.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final progressWidth = constraints.maxWidth * progress;
        final bool isTextInside = progressWidth > 52;

        return Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            Container(
              height: height,
              width: progressWidth,
              decoration: BoxDecoration(
                color: AppColors.primaryButton,
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
                    color: isTextInside ? Colors.black : Colors.black,
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
