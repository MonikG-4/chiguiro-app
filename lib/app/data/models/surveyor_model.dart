import 'package:hive/hive.dart';

import '../../domain/entities/surveyor.dart';

part 'surveyor_model.g.dart';

@HiveType(typeId: 5)
class SurveyorModel extends HiveObject {
  @HiveField(0)
  final int totalEntries;
  @HiveField(1)
  final String lastSurvey;


  SurveyorModel({
    required this.totalEntries,
    required this.lastSurvey,
  });

  factory SurveyorModel.fromEntity(Surveyor entity) {
    return SurveyorModel(
      totalEntries: entity.totalEntries,
      lastSurvey: entity.lastSurvey,
    );
  }

  factory SurveyorModel.fromJson(Map<String, dynamic> json) {
    return SurveyorModel(
      totalEntries: json['totalEntries'],
      lastSurvey: json['lastSurvey'],
    );
  }

  Surveyor toEntity() {
    return Surveyor(
      totalEntries: totalEntries,
      lastSurvey: lastSurvey,
    );
  }
}
