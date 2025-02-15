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

  factory Sections.fromJson(Map<String, dynamic> json) {
    return Sections(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sort: json['sort'],
      surveyQuestion: (json['questions'] as List)
          .map((q) => SurveyQuestion.fromJson(q))
          .toList(),
    );
  }
}