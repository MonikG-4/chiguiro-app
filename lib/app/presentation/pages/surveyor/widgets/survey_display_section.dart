import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/survey.dart';
import '../../../../domain/entities/survey_responded.dart';
import '../pages/home/widgets/response_survey_list.dart';
import '../pages/home/widgets/survey_card.dart';

class SurveyDisplaySection extends StatelessWidget {
  final String title;
  final List<dynamic> surveys;
  final bool isResponded;
  final void Function(Survey)? onSurveyTap;
  final RxBool? isLoading;

  const SurveyDisplaySection({
    super.key,
    required this.title,
    required this.surveys,
    this.isResponded = false,
    this.onSurveyTap,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final filteredSurveys = isResponded
        ? surveys
        : surveys.where((s) => s.active == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (filteredSurveys.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No hay encuestas disponibles",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (isResponded)
          ResponseSurveyList(
            surveyResponded: filteredSurveys as List<SurveyResponded>,
            isLoadingAnswerSurvey: isLoading!,
          )
        else
          Column(
            children: filteredSurveys.map((survey) {
              return SurveyCard(
                survey: survey,
                onTap: () => onSurveyTap?.call(survey as Survey),
              );
            }).toList(),
          ),
      ],
    );
  }
}
