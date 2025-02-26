import 'package:flutter/material.dart';

import '../../../../../core/values/app_colors.dart';

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
    this.barColor = AppColors.successBorder,
    this.spacing = 1,
  });


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
    double total = values.fold(0, (sum, value) => sum + value);

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double totalSpacing = spacing * (values.length - 1);
        double barWidth = (availableWidth - totalSpacing) / values.length;

        return SizedBox(
          width: availableWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (index) {
              double normalizedHeight = _calculateNormalizedHeight(
                values[index],
                maxValue == 0 ? 0 : maxValue,
                maxValue == 0 ? 700 :  maxHeight ,
              );

              double percentage = total == 0 ? 0 : (values[index] / total) * 100;


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
                        child: Center(
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weekDays[index],
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