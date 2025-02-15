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
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'],
      question: json['question'],
      description: json['description'],
      sort: json['sort'],
      type: json['type'],
      mandatory: json['mandatory'],
      meta: List<String>.from(json['meta']),
      meta2: List<String>.from(json['meta2']),
      anchorMin: json['anchorMin'],
      anchorMax: json['anchorMax'],
      scaleMin: json['scaleMin'],
      scaleMax: json['scaleMax'],
    );
  }
}
