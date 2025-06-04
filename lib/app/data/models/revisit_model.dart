import 'package:hive/hive.dart';

part 'revisit_model.g.dart';

@HiveType(typeId: 9)
class RevisitModel extends HiveObject {
  @HiveField(0)
  final String homeCode;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final int totalSurveys;

  @HiveField(4)
  final String address;

  @HiveField(5)
  final int revisitNumber;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String reason;

  RevisitModel({
    required this.homeCode,
    required this.latitude,
    required this.longitude,
    required this.totalSurveys,
    required this.address,
    required this.revisitNumber,
    required this.date,
    required this.reason,
  });

  factory RevisitModel.fromJson(Map<String, dynamic> json) {
    return RevisitModel(
      homeCode: json['homeCode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      totalSurveys: json['totalSurveys'],
      address: json['address'],
      revisitNumber: json['revisitNumber'],
      date: DateTime.parse(json['date']),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homeCode': homeCode,
      'latitude': latitude,
      'longitude': longitude,
      'totalSurveys': totalSurveys,
      'address': address,
      'revisitNumber': revisitNumber,
      'date': date.toIso8601String(),
      'reason': reason,
    };
  }

  RevisitModel copyWith({
    String? homeCode,
    double? latitude,
    double? longitude,
    int? totalSurveys,
    String? address,
    int? revisitNumber,
    DateTime? date,
    String? reason,
  }) {
    return RevisitModel(
      homeCode: homeCode ?? this.homeCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalSurveys: totalSurveys ?? this.totalSurveys,
      address: address ?? this.address,
      revisitNumber: revisitNumber ?? this.revisitNumber,
      date: date ?? this.date,
      reason: reason ?? this.reason,
    );
  }
}
