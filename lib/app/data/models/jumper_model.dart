import 'package:hive/hive.dart';

import '../../domain/entities/jumper.dart';

part 'jumper_model.g.dart';

@HiveType(typeId: 7)
class JumperModel extends HiveObject {
  @HiveField(0)
  final String? value;

  @HiveField(1)
  final int? questionNumber;

  JumperModel({
    required this.value,
    required this.questionNumber,
  });

  factory JumperModel.fromEntity(Jumper jumper) {
    return JumperModel(
      value: jumper.value,
      questionNumber: jumper.questionNumber,
    );
  }

  factory JumperModel.fromJson(Map<String, dynamic> json) {
    return JumperModel(
      value: json['value'],
      questionNumber: json['questionNumber'],
    );
  }

  Jumper toEntity() {
    return Jumper(
      value: value,
      questionNumber: questionNumber,
    );
  }
}