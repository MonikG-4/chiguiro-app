import 'package:chiguiro_front_app/core/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../domain/entities/detail_survey.dart';
import '../../../../../controllers/detail_survey_controller.dart';

class ResponseStatusList extends StatelessWidget {
  final DetailSurveyController controller = Get.find();
  final ConnectivityService _connectivityService = Get.find();

  ResponseStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() => ListView.separated(
        controller: controller.scrollController,
        itemCount: _getItemCount(),
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFE8EDF4),
        ),
        itemBuilder: (context, index) {
          if (index == controller.detailSurvey.length) {
            return _buildLoadingIndicator();
          }
          final item = controller.detailSurvey[index];
          return _buildItem(item);
        },
      )),
    );
  }

  int _getItemCount() {
    if (controller.currentPage.value == 1 && controller.detailSurvey.length < controller.pageSize) {
      return controller.detailSurvey.length;
    }
    return controller.detailSurvey.length + (controller.isLastPage.value ? 0 : 1);
  }

  Widget _buildLoadingIndicator() {
    return _connectivityService.isConnected.value ? const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(color: Colors.black,),
      ),
    ) : const Text('No hay datos por mostrar', textAlign: TextAlign.center,);
  }

  Widget _buildItem(DetailSurvey item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              _formatDate(item.createdOn),
              style: const TextStyle(
                color: Color(0xFF6C7A9C),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.answerPercentage,
              style: const TextStyle(
                color: Color(0xFF6C7A9C),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: item.completed ? const Color(0xFF1DD1A1) : const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                item.completed ? 'Completo' : 'Incompleto',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getSpanishMonth(date.month).substring(0, 3).toLowerCase();
    final year = date.year.toString().substring(2);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day. $month. $year  $hour:$minute';
  }
  String _getSpanishMonth(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}