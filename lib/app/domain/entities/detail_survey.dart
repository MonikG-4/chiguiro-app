class DetailSurvey {
  final int id;
  final DateTime createdOn;
  final String answerPercentage;
  final bool completed;

  DetailSurvey({
    required this.id,
    required this.createdOn,
    required this.answerPercentage,
    required this.completed,
  });

  factory DetailSurvey.fromJson(Map<String, dynamic> json) {
    return DetailSurvey(
      id: int.tryParse(json['id'].toString()) ?? 0,
      createdOn: DateTime.parse(json['createdOn']),
      answerPercentage: json['statistic']['answerPercentage'],
      completed: json['statistic']['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdOn': createdOn,
      'answerPercentage': answerPercentage,
      'completed': completed,
    };
  }
}
