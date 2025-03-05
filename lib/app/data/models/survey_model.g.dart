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
      closeDate: fields[3] as DateTime?,
      entriesCount: fields[4] as int,
      logoUrl: fields[5] as String?,
      geoLocation: fields[6] as bool,
      voiceRecorder: fields[7] as bool,
      sections: (fields[8] as List).cast<SectionsModel>(),
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
      ..write(obj.closeDate)
      ..writeByte(4)
      ..write(obj.entriesCount)
      ..writeByte(5)
      ..write(obj.logoUrl)
      ..writeByte(6)
      ..write(obj.geoLocation)
      ..writeByte(7)
      ..write(obj.voiceRecorder)
      ..writeByte(8)
      ..write(obj.sections);
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
