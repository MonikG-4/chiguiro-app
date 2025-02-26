import 'package:flutter/material.dart';

import '../../../../../core/values/app_colors.dart';
import 'custom_card.dart';
import 'weekly_bar_chart.dart';

class SurveyDetailCard extends StatefulWidget {
  final int responses;
  final String lastSurveyDate;
  final List<String> weekDays;
  final List<int> values;

  const SurveyDetailCard({
    super.key,
    required this.responses,
    required this.lastSurveyDate,
    required this.weekDays,
    required this.values,
  });

  @override
  State<SurveyDetailCard> createState() => _SurveyDetailCardState();
}

class _SurveyDetailCardState extends State<SurveyDetailCard> {

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBalanceSection(),
            _buildSurveyInfoSection(),

          ],
        ),
        SizedBox(
          width: double.infinity,
          child: WeeklyBarChart(
            values: widget.values.map((e) => e.toDouble()).toList(),
            weekDays: widget.weekDays,
          ),
        )
      ],
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceHeader(),
        _buildVisibleBalanceInfo()

      ],
    );
  }

  Widget _buildBalanceHeader() {
    return const Row(
      children: [
        Text(
          'TU ACTIVIDAD',
          style: TextStyle(color: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _buildVisibleBalanceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Respuestas:',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondary,
          ),
        ),
        Text(
          '${widget.responses}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Última encuesta',
          style: TextStyle(color: AppColors.primary),
        ),
        Text(
          widget.lastSurveyDate,
          style: const TextStyle(color: AppColors.secondary),
        ),
      ],
    );
  }


}
