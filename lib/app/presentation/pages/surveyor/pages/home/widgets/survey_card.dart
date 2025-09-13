import 'package:flutter/material.dart';

import '../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../domain/entities/survey.dart';

class SurveyCard extends StatelessWidget {
  final Survey survey;
  final VoidCallback onTap;

  const SurveyCard({
    required this.survey,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: _buildLeadingIcon(),
          title: _buildTitle(),
          subtitle: _buildSubtitle(),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return (survey.imageUrl != null && survey.imageUrl != '') ? ClipRRect(
      borderRadius:  BorderRadius.circular(10),
      child: Image.network(
        survey.imageUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.dashboard_sharp, size: 40),
      ),
    ) :  Image.asset(
      'assets/images/icons/Encuesta2.png',
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
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        survey.active
            ? Text(
                survey.active ? 'En proceso' : 'Finalizada',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColorScheme.primary,
                ),
              )
            : const SizedBox(
                height: 4,
              ),
      ],
    );
  }
}
