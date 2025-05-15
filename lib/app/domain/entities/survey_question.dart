import 'jumper.dart';

class SurveyQuestion {
  final String id;
  final String question;
  final String? description;
  final int sort;
  final String type;
  final bool mandatory;
  final List<String> meta;
  final List<String>? meta2;
  final String? anchorMin;
  final String? anchorMax;
  final int? scaleMin;
  final int? scaleMax;
  final List<Jumper>? jumpers;

  SurveyQuestion({
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
    this.jumpers,
  });

  @override
  String toString() {
    return 'SurveyQuestion(id: $id, question: $question, description: $description, sort: $sort, type: $type, mandatory: $mandatory, meta: $meta, meta2: $meta2, anchorMin: $anchorMin, anchorMax: $anchorMax, scaleMin: $scaleMin, scaleMax: $scaleMax, jumpers: $jumpers)';
  }
}
