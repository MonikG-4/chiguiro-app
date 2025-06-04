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
      homeCode: fields[0] as String,
      projectId: fields[1] as int,
      pollsterId: fields[2] as int,
      audio: fields[3] as String?,
      answers: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      latitude: fields[5] as String?,
      longitude: fields[6] as String?,
      startedOn: fields[7] as String,
      finishedOn: fields[8] as String,
      comments: fields[9] as String?,
      revisit: fields[10] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyEntryModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.homeCode)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.pollsterId)
      ..writeByte(3)
      ..write(obj.audio)
      ..writeByte(4)
      ..write(obj.answers)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.startedOn)
      ..writeByte(8)
      ..write(obj.finishedOn)
      ..writeByte(9)
      ..write(obj.comments)
      ..writeByte(10)
      ..write(obj.revisit);
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
