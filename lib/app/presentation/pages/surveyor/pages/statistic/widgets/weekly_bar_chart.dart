import 'package:flutter/material.dart';

import '../../../../../../../core/theme/app_colors_theme.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> weekDays;
  final double maxHeight;
  final Color barColor;
  final double spacing;

  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.weekDays,
    this.maxHeight = 150,
    this.barColor = AppColorScheme.primary,
    this.spacing = 1,
  });

  double _calculateNormalizedHeight(double value, double maxValue, double availableHeight) {
    final maxBarHeight = availableHeight - 30;
    const scaleFactor = 0.85;
    const minBarHeight = 15.0;

    if (value == 0) return maxBarHeight * 0.2;

    final calculated = (value / maxValue) * maxBarHeight * scaleFactor;
    return calculated < minBarHeight ? minBarHeight : calculated;
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final totalSpacing = spacing * (values.length - 1);
        final barWidth = (availableWidth - totalSpacing) / values.length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(values.length, (index) {
            final value = values[index];
            final label = weekDays[index];
            final height = _calculateNormalizedHeight(value, maxValue, maxHeight);

            return SizedBox(
              width: barWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barWidth * 0.9,
                    height: height,
                    decoration: BoxDecoration(
                      color: value > 0 ? AppColorScheme.primary : AppColorScheme.primary.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${value.toInt()}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 8, color: Color(0xFF6C7A9C)),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
