import 'package:flutter/material.dart';
import '../../../../../../../core/values/app_colors.dart';
import '../../../widgets/custom_card.dart';
import 'weekly_bar_chart.dart';

class SurveyDetailCard extends StatefulWidget {
  final bool isLoading;
  final int responses;
  final String lastSurveyDate;
  final List<String> weekDays;
  final List<int> values;

  const SurveyDetailCard({
    super.key,
    required this.isLoading,
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
      children: widget.isLoading
          ? [
              const SizedBox(
                height: 216,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            ]
          : [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceSection(widget.responses),
                  _buildSurveyInfoSection(widget.lastSurveyDate),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: WeeklyBarChart(
                  values: (widget.values.isEmpty)
                      ? [0.0, 0.0]
                      : widget.values.map((e) => e.toDouble()).toList(),
                  weekDays: widget.weekDays,
                ),
              ),
            ],
    );
  }

  Widget _buildBalanceSection(int responses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceHeader(),
        _buildVisibleBalanceInfo(responses),
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

  Widget _buildVisibleBalanceInfo(int responses) {
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
          '$responses',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyInfoSection(String? lastSurveyDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Última encuesta',
          style: TextStyle(color: AppColors.primary),
        ),
        Text(
          _formatDate(lastSurveyDate!),
          style: const TextStyle(color: AppColors.secondary),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    try {
      DateTime date = DateTime.parse(isoDate);
      return '${date.day}. ${months[date.month - 1]}. ${date.year}  ${date.hour}:${date.minute}';
    } catch (e) {
      return '-- -- -- --';
    }
  }
}
