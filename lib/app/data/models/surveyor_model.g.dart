// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surveyor_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyorModelAdapter extends TypeAdapter<SurveyorModel> {
  @override
  final int typeId = 5;

  @override
  SurveyorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyorModel(
      totalEntries: fields[0] as int,
      lastSurvey: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyorModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.totalEntries)
      ..writeByte(1)
      ..write(obj.lastSurvey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
