class AuthResponse {
  final int id;
  final String accessToken;
  final int projectId;

  AuthResponse({
    required this.id,
    required this.accessToken,
    required this.projectId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: _parseIntSafely(json['id']),
      accessToken: json['accessToken'] ?? '',
      projectId: _parseIntSafely(json['project']?['id']) != 0
          ? _parseIntSafely(json['project']?['id'])
          : _parseIntSafely(json['projectId']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accessToken': accessToken,
        'projectId': projectId,
      };

  static int _parseIntSafely(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
