// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_statistics_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyStatisticsModelAdapter extends TypeAdapter<SurveyStatisticsModel> {
  @override
  final int typeId = 6;

  @override
  SurveyStatisticsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyStatisticsModel(
      totalEntries: fields[0] as int,
      totalCompleted: fields[1] as int,
      totalUncompleted: fields[2] as int,
      completedPercentage: fields[3] as String,
      lastSurvey: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyStatisticsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.totalEntries)
      ..writeByte(1)
      ..write(obj.totalCompleted)
      ..writeByte(2)
      ..write(obj.totalUncompleted)
      ..writeByte(3)
      ..write(obj.completedPercentage)
      ..writeByte(4)
      ..write(obj.lastSurvey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyStatisticsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
