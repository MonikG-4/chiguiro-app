// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyEntryModelAdapter extends TypeAdapter<SurveyEntryModel> {
  @override
  final int typeId = 1;

  @override
  SurveyEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyEntryModel(
      projectId: fields[0] as int,
      pollsterId: fields[1] as int,
      audio: fields[2] as String?,
      answers: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      latitude: fields[4] as String?,
      longitude: fields[5] as String?,
      startedOn: fields[6] as String,
      finishedOn: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyEntryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.pollsterId)
      ..writeByte(2)
      ..write(obj.audio)
      ..writeByte(3)
      ..write(obj.answers)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.startedOn)
      ..writeByte(7)
      ..write(obj.finishedOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
