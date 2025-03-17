// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_responded_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyRespondedModelAdapter extends TypeAdapter<SurveyRespondedModel> {
  @override
  final int typeId = 8;

  @override
  SurveyRespondedModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyRespondedModel(
      totalEntries: fields[0] as int,
      lastSurvey: fields[1] as DateTime,
      surveyId: fields[2] as int,
      surveyName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyRespondedModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalEntries)
      ..writeByte(1)
      ..write(obj.lastSurvey)
      ..writeByte(2)
      ..write(obj.surveyId)
      ..writeByte(3)
      ..write(obj.surveyName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyRespondedModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
