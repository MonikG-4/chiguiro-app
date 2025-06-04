import 'package:hive/hive.dart';

part 'survey_entry_model.g.dart';

@HiveType(typeId: 1)
class SurveyEntryModel {
  @HiveField(0)
  final String homeCode;

  @HiveField(1)
  final int projectId;

  @HiveField(2)
  final int pollsterId;

  @HiveField(3)
  final String? audio;

  @HiveField(4)
  final List<Map<String, dynamic>> answers;

  @HiveField(5)
  final String? latitude;

  @HiveField(6)
  final String? longitude;

  @HiveField(7)
  final String startedOn;

  @HiveField(8)
  final String finishedOn;

  @HiveField(9)
  final String? comments;

  @HiveField(10)
  final bool? revisit;

  SurveyEntryModel({
    required this.homeCode,
    required this.projectId,
    required this.pollsterId,
    this.audio,
    required this.answers,
    this.latitude,
    this.longitude,
    required this.startedOn,
    required this.finishedOn,
    this.comments,
    this.revisit,
  });

  factory SurveyEntryModel.fromJson(Map<String, dynamic> json) {
    return SurveyEntryModel(
      homeCode: json['homeCode'],
      projectId: json['projectId'],
      pollsterId: json['pollsterId'],
      audio: json['audioBase64'],
      answers: List<Map<String, dynamic>>.from(json['answers']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      startedOn: json['startedOn'],
      finishedOn: json['finishedOn'],
      comments: json['comments'],
      revisit: json['revisit'],
    );
  }

  factory SurveyEntryModel.fromMap(Map<String, dynamic> map) {
    return SurveyEntryModel(
      homeCode: map['homeCode'],
      projectId: map['projectId'],
      pollsterId: map['pollsterId'],
      audio: map['audio'],
      answers: List<Map<String, dynamic>>.from(map['answers']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      startedOn: map['startedOn'],
      finishedOn: map['finishedOn'],
      comments: map['comments'],
      revisit: map['revisit'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'homeCode': homeCode,
      'projectId': projectId,
      'pollsterId': pollsterId,
      'answers': answers,
      'startedOn': startedOn,
      'finishedOn': finishedOn,
      if (audio != null && audio!.isNotEmpty) 'audio': audio,
      if (latitude != null && latitude!.isNotEmpty) 'latitude': latitude,
      if (longitude != null && longitude!.isNotEmpty) 'longitude': longitude,
      if (comments != null && comments!.isNotEmpty) 'comments': comments,
      if (revisit != null) 'revisit': revisit,
    };

    return data;
  }

}
