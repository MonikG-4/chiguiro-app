class Survey {
  final String id;
  final String name;
  final String organization;
  final DateTime closeDate;
  final int responses;
  final String? logoUrl;

  Survey({
    required this.id,
    required this.name,
    required this.organization,
    required this.closeDate,
    required this.responses,
    this.logoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'closeDate': closeDate,
      'responses': responses,
      'logoUrl': logoUrl,
    };
  }
}