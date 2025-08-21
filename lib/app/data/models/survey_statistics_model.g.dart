// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_statistics_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatisticsModelAdapter extends TypeAdapter<StatisticsModel> {
  @override
  final int typeId = 6;

  @override
  StatisticsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatisticsModel(
      homes: fields[0] as int,
      entries: fields[1] as int,
      completedPercent: fields[2] as double,
      duration: fields[3] as double,
      days: (fields[4] as List).cast<StatisticDayModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, StatisticsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.homes)
      ..writeByte(1)
      ..write(obj.entries)
      ..writeByte(2)
      ..write(obj.completedPercent)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
