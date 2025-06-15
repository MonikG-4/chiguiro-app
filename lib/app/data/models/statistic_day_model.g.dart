// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistic_day_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatisticDayModelAdapter extends TypeAdapter<StatisticDayModel> {
  @override
  final int typeId = 10;

  @override
  StatisticDayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatisticDayModel(
      date: fields[0] as DateTime,
      entries: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StatisticDayModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.entries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticDayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
