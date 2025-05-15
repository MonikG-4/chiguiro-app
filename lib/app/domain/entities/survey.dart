import 'sections.dart';

class Survey {
  final int id;
  final String name;
  final bool active;
  final DateTime? lastSurvey;
  final int entriesCount;
  final bool geoLocation;
  final bool voiceRecorder;
  final List<Sections> sections;

  Survey({
    required this.id,
    required this.name,
    required this.active,
    this.lastSurvey,
    required this.entriesCount,
    required this.geoLocation,
    required this.voiceRecorder,
    required this.sections
  });

  @override
  String toString() {
    return 'Survey(id: $id, name: $name, active: $active, lastSurvey: $lastSurvey, entriesCount: $entriesCount, geoLocation: $geoLocation, voiceRecorder: $voiceRecorder, sections: $sections)';
  }
}
