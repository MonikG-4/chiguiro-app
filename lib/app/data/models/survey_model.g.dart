// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyModelAdapter extends TypeAdapter<SurveyModel> {
  @override
  final int typeId = 2;

  @override
  SurveyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyModel(
      id: fields[0] as int,
      name: fields[1] as String,
      active: fields[2] as bool,
      lastSurvey: fields[3] as DateTime?,
      entriesCount: fields[4] as int,
      geoLocation: fields[5] as bool,
      voiceRecorder: fields[6] as bool,
      sections: (fields[7] as List).cast<SectionsModel>(),
      imageUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.active)
      ..writeByte(3)
      ..write(obj.lastSurvey)
      ..writeByte(4)
      ..write(obj.entriesCount)
      ..writeByte(5)
      ..write(obj.geoLocation)
      ..writeByte(6)
      ..write(obj.voiceRecorder)
      ..writeByte(7)
      ..write(obj.sections)
      ..writeByte(8)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
