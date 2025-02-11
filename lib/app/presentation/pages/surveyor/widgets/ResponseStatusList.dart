import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/detail_survey.dart';
import '../../../controllers/detail_survey_controller.dart';

class ResponseStatusList extends StatelessWidget {
  final DetailSurveyController controller = Get.find();

  ResponseStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() => ListView.separated(
        controller: controller.scrollController,
        itemCount: controller.detailSurvey.length + 1,
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(color: Colors.black,),
      ),
    );
  }

  Widget _buildItem(DetailSurvey item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    return '$day. $month. $year';
  }

  String _getSpanishMonth(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}
