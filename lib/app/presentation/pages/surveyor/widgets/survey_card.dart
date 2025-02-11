import 'package:flutter/material.dart';

import '../../../../../core/values/app_colors.dart';
import '../../../../domain/entities/survey.dart';

class SurveyCard extends StatelessWidget {
  final Survey survey;
  final bool isHistorical;
  final VoidCallback onTap;

  const SurveyCard({
    required this.survey,
    required this.onTap,
    this.isHistorical = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: _buildLeadingIcon(),
            title: _buildTitle(),
            subtitle: _buildSubtitle(),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    var logoUrl =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFe4BEwG37Mv0M724WYCTjsNP2UojEL3Oa0Q&s';
    return logoUrl.isEmpty
        ? const Icon(Icons.business, size: 40)
        : Image.network(
            logoUrl,
            width: 60,
            height: 60,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.business,
              size: 40,
            ),
          );
  }

  Widget _buildTitle() {
    return Text(
      survey.name,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isHistorical ? AppColors.secondary : null,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          survey.active ? 'En proceso' : 'Finalizada',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondary,
          ),
        ),
        _buildResponsesInfo(),
      ],
    );
  }

  Widget _buildResponsesInfo() {
    return Row(
      children: [
        Icon(
          Icons.description_outlined,
          size: 16,
          color: isHistorical ? AppColors.secondary : AppColors.successText,
        ),
        const SizedBox(width: 4),
        Text(
          '${survey.entriesCount} respuestas',
          style: TextStyle(
            fontSize: 12,
            color: isHistorical ? AppColors.secondary : AppColors.successText,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
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
    return '${date.day}. ${months[date.month - 1]}. ${date.year}';
  }
}
