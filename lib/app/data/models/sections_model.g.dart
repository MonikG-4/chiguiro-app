// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sections_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SectionsModelAdapter extends TypeAdapter<SectionsModel> {
  @override
  final int typeId = 4;

  @override
  SectionsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SectionsModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      sort: fields[3] as int,
      surveyQuestion: (fields[4] as List).cast<SurveyQuestionModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, SectionsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.sort)
      ..writeByte(4)
      ..write(obj.surveyQuestion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
