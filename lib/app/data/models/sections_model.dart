import 'package:hive/hive.dart';

import '../../domain/entities/sections.dart';
import 'survey_question_model.dart';

part 'sections_model.g.dart';

@HiveType(typeId: 4)
class SectionsModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int sort;

  @HiveField(4)
  final List<SurveyQuestionModel> surveyQuestion;

  SectionsModel({
    required this.id,
    required this.name,
    this.description,
    required this.sort,
    required this.surveyQuestion,
  });

  factory SectionsModel.fromJson(Map<String, dynamic> json) {
    return SectionsModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sort: json['sort'],
      surveyQuestion: (json['questions'] as List)
          .map((q) => SurveyQuestionModel.fromJson(q))
          .toList(),
    );
  }

  factory SectionsModel.fromEntity(Sections section) {
    return SectionsModel(
      id: section.id,
      name: section.name,
      description: section.description,
      sort: section.sort,
      surveyQuestion: section.surveyQuestion
          .map((q) => SurveyQuestionModel.fromEntity(q))
          .toList(),
    );
  }

  Sections toEntity() {
    return Sections(
      id: id,
      name: name,
      description: description,
      sort: sort,
      surveyQuestion: surveyQuestion.map((q) => q.toEntity()).toList(),
    );
  }
}