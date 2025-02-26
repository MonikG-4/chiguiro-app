import 'package:hive/hive.dart';

part 'survey_entry_model.g.dart';

@HiveType(typeId: 1)
class SurveyEntryModel {
  @HiveField(0)
  final int projectId;

  @HiveField(1)
  final int pollsterId;

  @HiveField(2)
  final String? audio;

  @HiveField(3)
  final List<Map<String, dynamic>> answers;

  @HiveField(4)
  final String? latitude;

  @HiveField(5)
  final String? longitude;

  @HiveField(6)
  final String startedOn;

  @HiveField(7)
  final String finishedOn;

  SurveyEntryModel({
    required this.projectId,
    required this.pollsterId,
    this.audio,
    required this.answers,
    this.latitude,
    this.longitude,
    required this.startedOn,
    required this.finishedOn,
  });

  factory SurveyEntryModel.fromJson(Map<String, dynamic> json) {
    return SurveyEntryModel(
      projectId: json['projectId'],
      pollsterId: json['pollsterId'],
      audio: json['audioBase64'],
      answers: List<Map<String, dynamic>>.from(json['answers']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      startedOn: json['startedOn'],
      finishedOn: json['finishedOn'],
    );
  }

  factory SurveyEntryModel.fromMap(Map<String, dynamic> map) {
    return SurveyEntryModel(
      projectId: map['projectId'],
      pollsterId: map['pollsterId'],
      audio: map['audio'],
      answers: List<Map<String, dynamic>>.from(map['answers']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      startedOn: map['startedOn'],
      finishedOn: map['finishedOn'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'projectId': projectId,
      'pollsterId': pollsterId,
      'answers': answers,
      'startedOn': startedOn,
      'finishedOn': finishedOn,
      if (audio != null && audio!.isNotEmpty) 'audio': audio,
      if (latitude != null && latitude!.isNotEmpty) 'latitude': latitude,
      if (longitude != null && longitude!.isNotEmpty) 'longitude': longitude,
    };

    return data;
  }

}
