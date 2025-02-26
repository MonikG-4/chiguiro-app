import 'package:hive/hive.dart';

import '../../domain/entities/surveyor.dart';
import 'survey_statistics_model.dart';

part 'surveyor_model.g.dart';

@HiveType(typeId: 5)
class SurveyorModel extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String surname;
  @HiveField(2)
  final SurveyStatisticsModel statics;
  @HiveField(3)
  final double? balance;
  @HiveField(4)
  final int? responses;
  @HiveField(5)
  final double? growthRate;

  SurveyorModel({
    required this.name,
    required this.surname,
    required this.statics,
    this.balance,
    this.responses,
    this.growthRate,
  });

  factory SurveyorModel.fromEntity(Surveyor entity) {
    return SurveyorModel(
      name: entity.name,
      surname: entity.surname,
      statics: SurveyStatisticsModel.fromEntity(entity.statics),
      balance: entity.balance,
      responses: entity.responses,
      growthRate: entity.growthRate,
    );
  }

  factory SurveyorModel.fromJson(Map<String, dynamic> json) {
    return SurveyorModel(
      name: json['name'],
      surname: json['surname'],
      statics: SurveyStatisticsModel.fromJson(json['statistic']),
    );
  }

  Surveyor toEntity() {
    return Surveyor(
      name: name,
      surname: surname,
      statics: statics.toEntity(),
    );
  }
}
