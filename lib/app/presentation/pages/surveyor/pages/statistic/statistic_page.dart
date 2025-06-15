import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../controllers/statistic_controller.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';
import 'widgets/weekly_bar_chart.dart';

class StatisticPage extends GetView<StatisticController> {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final values = controller.values;
      final labels = controller.weekDays;

      return BodyWrapper(
        onRefresh: () async => controller.fetchStatistics(),
        child: CustomCard(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Text(
                    'Estadísticas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                // Grid de métricas
                Obx(() {
                  final data = controller.statistics.value;

                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (data == null) {
                    return const Center(
                        child: Text("No hay datos disponibles"));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final double cardWidth = (constraints.maxWidth -4) / 2;

                      return Wrap(
                        spacing: 4,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Hogares encuestados',
                              icon: Icons.home_outlined,
                              value: '${data.homes}',
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Encuestas realizadas',
                              icon: Icons.assignment_outlined,
                              value: '${data.entries}',
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Tasa de finalización',
                              icon: Icons.check_circle_outline,
                              value:
                                  '${data.completedPercent.toStringAsFixed(0)}%',
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _StatCard(
                              title: 'Duración promedio',
                              icon: Icons.timer_outlined,
                              value: controller.formattedDuration,
                              valueSuffix: 'min',
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),

                const SizedBox(height: 16),

                // Mostrar gráfica solo si hay datos
                if (controller.statistics.value != null &&
                    controller.statistics.value!.days.isNotEmpty)
                  CustomCard(
                    color: const Color(0xFFEFF6FF),
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.graphicBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bar_chart,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Respuestas en el tiempo',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: controller.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : WeeklyBarChart(values: values, weekDays: labels),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String? valueSuffix;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.value,
    this.valueSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: const Color(0xFFE9F9F1),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.iconsStatistic,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisAlignment: MainAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (valueSuffix != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  valueSuffix!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
