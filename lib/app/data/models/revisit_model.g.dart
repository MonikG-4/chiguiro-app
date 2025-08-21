// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revisit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RevisitModelAdapter extends TypeAdapter<RevisitModel> {
  @override
  final int typeId = 9;

  @override
  RevisitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RevisitModel(
      homeCode: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      totalSurveys: fields[3] as int,
      address: fields[4] as String,
      revisitNumber: fields[5] as int,
      date: fields[6] as DateTime,
      reason: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RevisitModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.homeCode)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.totalSurveys)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.revisitNumber)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevisitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
