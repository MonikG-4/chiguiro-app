class Survey {
  final int id;
  final String name;
  final bool active;
  final DateTime? closeDate;
  final int entriesCount;
  final String? logoUrl;
  final bool geoLocation;
  final bool voiceRecorder;

  Survey({
    required this.id,
    required this.name,
    required this.active,
    this.closeDate,
    required this.entriesCount,
    this.logoUrl,
    required this.geoLocation,
    required this.voiceRecorder,
  });
}
