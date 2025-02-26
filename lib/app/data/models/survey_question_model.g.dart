// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_question_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyQuestionModelAdapter extends TypeAdapter<SurveyQuestionModel> {
  @override
  final int typeId = 3;

  @override
  SurveyQuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyQuestionModel(
      id: fields[0] as String,
      question: fields[1] as String,
      description: fields[2] as String?,
      sort: fields[3] as int,
      type: fields[4] as String,
      mandatory: fields[5] as bool,
      meta: (fields[6] as List).cast<String>(),
      meta2: (fields[7] as List?)?.cast<String>(),
      anchorMin: fields[8] as String?,
      anchorMax: fields[9] as String?,
      scaleMin: fields[10] as int?,
      scaleMax: fields[11] as int?,
      jumpers: (fields[12] as List?)?.cast<JumperModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, SurveyQuestionModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.sort)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.mandatory)
      ..writeByte(6)
      ..write(obj.meta)
      ..writeByte(7)
      ..write(obj.meta2)
      ..writeByte(8)
      ..write(obj.anchorMin)
      ..writeByte(9)
      ..write(obj.anchorMax)
      ..writeByte(10)
      ..write(obj.scaleMin)
      ..writeByte(11)
      ..write(obj.scaleMax)
      ..writeByte(12)
      ..write(obj.jumpers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyQuestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
