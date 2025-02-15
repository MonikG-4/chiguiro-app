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

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      active: json['active'],
      closeDate: json['closeDate'],
      entriesCount: json['entriesCount'],
      logoUrl: json['logoUrl'],
      geoLocation: json['geoLocation'],
      voiceRecorder: json['voiceRecorder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active': active,
      'closeDate': closeDate,
      'entriesCount': entriesCount,
      'logoUrl': logoUrl,
      'geoLocation': geoLocation,
      'voiceRecorder': voiceRecorder,
    };
  }


}