import 'package:hive/hive.dart';

import 'survey_entry_model.dart';

part 'sync_task_model.g.dart';

@HiveType(typeId: 0)
class SyncTaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String endpoint;

  @HiveField(2)
  SurveyEntryModel payload;

  @HiveField(3)
  bool isProcessing;

  @HiveField(4)
  String repositoryKey;

  SyncTaskModel({
    required this.id,
    required this.endpoint,
    required this.payload,
    this.isProcessing = false,
    required this.repositoryKey,
  });
}
