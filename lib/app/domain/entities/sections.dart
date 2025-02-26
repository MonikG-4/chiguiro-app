import 'survey_question.dart';

class Sections {
  final String id;
  final String name;
  final String? description;
  final int sort;
  final List<SurveyQuestion> surveyQuestion;

  Sections({
    required this.id,
    required this.name,
    this.description,
    required this.sort,
    required this.surveyQuestion,
  });
}