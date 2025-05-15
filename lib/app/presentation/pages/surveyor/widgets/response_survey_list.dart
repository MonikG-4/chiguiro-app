import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../core/values/app_colors.dart';
import '../../../../domain/entities/survey_responded.dart';

class ResponseSurveyList extends StatelessWidget {
  final List<SurveyResponded> surveyResponded;
  final RxBool isLoadingAnswerSurvey;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? maxHeight;

  ResponseSurveyList({
    super.key,
    required this.surveyResponded,
    required this.isLoadingAnswerSurvey,
    this.shrinkWrap = false,
    this.physics,
    this.maxHeight = 300,
  });

  final List<String> headers = ['Fecha', 'Formulario', 'Cantidad', 'Estado'];

  @override
  Widget build(BuildContext context) {
    print(surveyResponded);
    return Obx(() {
      if (isLoadingAnswerSurvey.value) {
        return const Center(
            child: CircularProgressIndicator(color: Colors.black));
      }

      return SizedBox(
        height: maxHeight,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 2, color: Color(0xFFE3EAF3)),
            Expanded(
              child: ListView.separated(
                physics: physics ?? const AlwaysScrollableScrollPhysics(),
                shrinkWrap: shrinkWrap,
                padding: EdgeInsets.zero,
                itemCount: surveyResponded.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFE3EAF3)),
                itemBuilder: (context, index) =>
                    _buildItem(surveyResponded[index]),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: headers.map((title) {
          final isEstado = title.toLowerCase() == 'estado' ||
              title.toLowerCase() == 'cantidad';
          return Expanded(
            flex: isEstado ? 2 : 3,
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 14),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItem(SurveyResponded item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              _formatDate(item.lastSurvey),
              style: const TextStyle(color: Color(0xFF6C7A9C), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.survey.name,
              style: const TextStyle(color: Color(0xFF6C7A9C), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.totalEntries.toString(),
              style: const TextStyle(color: Color(0xFF6C7A9C), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color:
                    // item.completed ? AppColors.complete : AppColors.incomplete,
                    AppColors.complete,
                shape: BoxShape.circle,
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
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }
}
