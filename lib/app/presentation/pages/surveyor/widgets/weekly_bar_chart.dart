import 'package:flutter/material.dart';

import '../../../../../core/values/app_colors.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<double> values;
  final double maxHeight;
  final Color barColor;
  final double spacing;

  WeeklyBarChart({
    super.key,
    required this.values,
    this.maxHeight = 200,
    this.barColor = AppColors.successBorder,
    this.spacing = 1,
  }) : assert(values.length == 7, 'Must provide exactly 7 values for the week');

  final List<String> _weekDays = [
    'Lun',
    'Mar',
    'Mie',
    'Jue',
    'Vie',
    'Sab',
    'Dom'
  ];

  double _calculateNormalizedHeight(double value, double maxValue, double availableHeight) {
    double maxBarHeight = availableHeight - 30;

    double scaleFactor = 0.85;

    if (value == 0) {
      return maxBarHeight * 0.1;
    }

    return (value / maxValue) * maxBarHeight * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    double maxValue = values.reduce((curr, next) => curr > next ? curr : next);

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double totalSpacing = spacing * 6;
        double barWidth = (availableWidth - totalSpacing) / 7;

        return SizedBox(
          width: availableWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              double normalizedHeight = _calculateNormalizedHeight(
                values[index],
                maxValue,
                maxHeight,
              );

              return SizedBox(
                width: barWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: values[index].toString(),
                      child: Container(
                        width: barWidth * 0.8,
                        height: normalizedHeight,
                        decoration: BoxDecoration(
                          color: values[index] > 0
                              ? barColor
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _weekDays[index],
                      style: const TextStyle(
                        color: Color(0xFF6C7A9C),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}