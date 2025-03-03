import 'package:flutter/material.dart';

import '../../../../../core/values/app_colors.dart';
import 'custom_card.dart';

class SurveyorBalanceCard extends StatefulWidget {
  final double balance;
  final int responses;
  final double growthRate;
  final String lastSurveyDate;

  const SurveyorBalanceCard({
    super.key,
    required this.balance,
    required this.responses,
    required this.growthRate,
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
        Row(
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
          widget.lastSurveyDate,
          style: const TextStyle(color: AppColors.secondary),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
