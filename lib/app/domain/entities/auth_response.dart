class AuthResponse {
  final int id;
  final String name;
  final String surname;
  final String accessToken;

  AuthResponse({
    required this.id,
    required this.name,
    required this.surname,
    required this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: _parseIntSafely(json['id']),
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      accessToken: json['accessToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'surname': surname,
        'accessToken': accessToken,
      };

  factory AuthResponse.empty() {
    return AuthResponse(
      id: 0,
      name: '',
      surname: '',
      accessToken: '',
    );
  }

  static int _parseIntSafely(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  String toString() {
    return 'AuthResponse(id: $id, name: $name, surname: $surname, accessToken: $accessToken)';
  }
}
