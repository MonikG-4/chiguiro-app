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
  bool _isBalanceVisible = true;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

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
      ],
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceHeader(),
        if (_isBalanceVisible)
          _buildVisibleBalanceInfo()
        else
          _buildHiddenBalanceInfo(),
      ],
    );
  }

  Widget _buildBalanceHeader() {
    return Row(
      children: [
        const Text(
          'TU BALANCE',
          style: TextStyle(color: AppColors.secondary),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _toggleBalanceVisibility,
          child: Icon(
            _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
            size: 20,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVisibleBalanceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$ ${widget.balance}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Respuestas: ${widget.responses}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondary,
          ),
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
        const SizedBox(height: 16),
        _buildGrowthRateIndicator(),
      ],
    );
  }

  Widget _buildGrowthRateIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            size: 20,
            color: Colors.green[700],
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.growthRate}%',
            style: const TextStyle(
              color: AppColors.successText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
