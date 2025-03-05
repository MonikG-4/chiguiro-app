import 'package:flutter/material.dart';

import '../../../../../core/values/app_colors.dart';
import 'custom_card.dart';

class SurveyorBalanceCard extends StatefulWidget {
  final bool isLoading;
  final int responses;
  final String lastSurveyDate;

  const SurveyorBalanceCard({
    super.key,
    required this.isLoading,
    required this.responses,
    required this.lastSurveyDate,
  });

  @override
  State<SurveyorBalanceCard> createState() => _SurveyorBalanceCardState();
}

class _SurveyorBalanceCardState extends State<SurveyorBalanceCard> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      children: [
        widget.isLoading
            ? const SizedBox(
              height: 75,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHiddenBalanceInfo(),
                  _buildSurveyInfoSection(),
                ],
              ),
      ],
    );
  }

  Widget _buildHiddenBalanceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Respuestas:',
          style: TextStyle(
            fontSize: 20,
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
          _formatDate(widget.lastSurveyDate),
          style: const TextStyle(color: AppColors.secondary),
        ),
        const SizedBox(height: 16),
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
