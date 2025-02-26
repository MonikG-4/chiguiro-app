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
      name: fields[0] as String,
      surname: fields[1] as String,
      statics: fields[2] as SurveyStatisticsModel,
      balance: fields[3] as double?,
      responses: fields[4] as int?,
      growthRate: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyorModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.surname)
      ..writeByte(2)
      ..write(obj.statics)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.responses)
      ..writeByte(5)
      ..write(obj.growthRate);
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
