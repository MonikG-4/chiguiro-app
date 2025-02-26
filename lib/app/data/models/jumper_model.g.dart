// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jumper_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JumperModelAdapter extends TypeAdapter<JumperModel> {
  @override
  final int typeId = 7;

  @override
  JumperModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JumperModel(
      value: fields[0] as String?,
      questionNumber: fields[1] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, JumperModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.questionNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JumperModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
