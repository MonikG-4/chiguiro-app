import 'package:hive/hive.dart';

import '../../domain/entities/survey_question.dart';
import 'jumper_model.dart';

part 'survey_question_model.g.dart';

@HiveType(typeId: 3)
class SurveyQuestionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int sort;

  @HiveField(4)
  final String type;

  @HiveField(5)
  final bool mandatory;

  @HiveField(6)
  final List<String> meta;

  @HiveField(7)
  final List<String>? meta2;

  @HiveField(8)
  final String? anchorMin;

  @HiveField(9)
  final String? anchorMax;

  @HiveField(10)
  final int? scaleMin;

  @HiveField(11)
  final int? scaleMax;

  @HiveField(12)
  final List<JumperModel>? jumpers;

  SurveyQuestionModel({
    required this.id,
    required this.question,
    this.description,
    required this.sort,
    required this.type,
    required this.mandatory,
    required this.meta,
    this.meta2,
    this.anchorMin,
    this.anchorMax,
    this.scaleMin,
    this.scaleMax,
    this.jumpers = const [],
  });

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) {
    return SurveyQuestionModel(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      description: json['description'] ?? '',
      sort: json['sort'] ?? 0,
      type: json['type'] ?? '',
      mandatory: json['mandatory'] ?? false,
      meta: List<String>.from(json['meta']),
      meta2: json['meta2'] != null ? List<String>.from(json['meta2']) : null,
      anchorMin: json['anchorMin'] ?? '',
      anchorMax: json['anchorMax'] ?? '',
      scaleMin: json['scaleMin'] ?? 0,
      scaleMax: json['scaleMax'] ?? 0,
      jumpers: json['jumpers'] != null
          ? (json['jumpers'] as List)
          .map((e) => JumperModel.fromJson(e))
          .toList()
          : [],
    );
  }

  factory SurveyQuestionModel.fromEntity(SurveyQuestion question) {
    return SurveyQuestionModel(
      id: question.id,
      question: question.question,
      description: question.description,
      sort: question.sort,
      type: question.type,
      mandatory: question.mandatory,
      meta: question.meta,
      meta2: question.meta2,
      anchorMin: question.anchorMin,
      anchorMax: question.anchorMax,
      scaleMin: question.scaleMin,
      scaleMax: question.scaleMax,
      jumpers: question.jumpers?.map((j) => JumperModel.fromEntity(j)).toList(),
    );
  }

  SurveyQuestion toEntity() {
    return SurveyQuestion(
      id: id,
      question: question,
      description: description,
      sort: sort,
      type: type,
      mandatory: mandatory,
      meta: meta,
      meta2: meta2,
      anchorMin: anchorMin,
      anchorMax: anchorMax,
      scaleMin: scaleMin,
      scaleMax: scaleMax,
      jumpers: jumpers?.map((j) => j.toEntity()).toList(),
    );
  }
}
