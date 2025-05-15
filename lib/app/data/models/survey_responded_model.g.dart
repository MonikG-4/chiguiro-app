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
      survey: fields[2] as SurveyModel,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyRespondedModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalEntries)
      ..writeByte(1)
      ..write(obj.lastSurvey)
      ..writeByte(2)
      ..write(obj.survey);
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
