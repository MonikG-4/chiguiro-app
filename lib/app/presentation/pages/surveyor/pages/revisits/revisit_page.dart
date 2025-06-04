import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../core/values/routes.dart';
import '../../../../controllers/revisits_controller.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/revisit_map_view.dart';

class RevisitsPage extends GetView<RevisitsController> {
  const RevisitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BodyWrapper(
      onRefresh: () async => controller.loadRevisits(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.revisits.isEmpty) {
              return const CustomCard(children: [
                Center(
                  child: Text(
                    'No hay revisitas guardadas',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ]);
            }

            return Column(
              children: [
                CustomCard(
                  children: [
                    const Text(
                      'Revisitas pendientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RevisitMapView(
                      coordinates: controller.revisits
                          .map((e) => LatLng(e.latitude, e.longitude))
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ...controller.revisits.map((revisit) {
                  final formattedDate =
                      DateFormat('d \'de\' MMMM \'de\' y', 'es')
                          .format(revisit.date);
                  return GestureDetector(
                    onTap: () async {
                      await Get.toNamed(Routes.REVISIT_DETAIL, arguments: revisit)?.then((_) => controller.loadRevisits());
                    },
                    child: CustomCard(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/min-deporte.png',
                              width: 50,
                              height: 50,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.home),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    revisit.address,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$formattedDate | ${revisit.totalSurveys} encuestas',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}
