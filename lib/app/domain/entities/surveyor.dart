import 'survey_statistics.dart';

class Surveyor {
  final String name;
  final String surname;
  final SurveyStatistics statics;
  final double? balance;
  final int? responses;
  final double? growthRate;

  Surveyor({
    required this.name,
    required this.surname,
    required this.statics,
    this.balance,
    this.responses,
    this.growthRate,
  });
}