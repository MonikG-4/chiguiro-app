import 'package:chiguiro_front_app/core/values/app_colors.dart';
import 'package:flutter/material.dart';

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

  // Función para calcular la altura normalizada con un factor de escala
  double _calculateNormalizedHeight(double value, double maxValue, double availableHeight) {
    // Reservamos espacio para el texto del día (20) y agregamos un padding superior (10)
    double maxBarHeight = availableHeight - 30;

    // Aplicamos un factor de escala del 85% para evitar que las barras sean demasiado altas
    double scaleFactor = 0.85;

    if (value == 0) {
      // Altura mínima para valores cero (10% de la altura máxima disponible)
      return maxBarHeight * 0.1;
    }

    // Calculamos la altura normalizada para valores no cero
    return (value / maxValue) * maxBarHeight * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    double maxValue = values.reduce((curr, next) => curr > next ? curr : next);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculamos el ancho disponible para cada barra
        double availableWidth = constraints.maxWidth;
        double totalSpacing = spacing * 6; // 6 espacios entre 7 barras
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