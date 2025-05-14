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
    return Image.asset(
      'assets/images/min-deporte.png',
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
        survey.active != null ?
        Text(
          survey.active! ? 'En proceso' : 'Finalizada',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondary,
          ),
        ) : const SizedBox(height: 4,),
      ],
    );
  }
}
