// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncTaskModelAdapter extends TypeAdapter<SyncTaskModel> {
  @override
  final int typeId = 0;

  @override
  SyncTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncTaskModel(
      id: fields[0] as String,
      surveyName: fields[1] as String,
      payload: fields[2] as SurveyEntryModel,
      isProcessing: fields[3] as bool,
      repositoryKey: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SyncTaskModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.surveyName)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.isProcessing)
      ..writeByte(4)
      ..write(obj.repositoryKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
