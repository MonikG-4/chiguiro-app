import 'user.dart';

class AuthResponse {
  final String accessToken;
  final DateTime createdOn;
  final DateTime expiredOn;
  final bool active;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.createdOn,
    required this.expiredOn,
    required this.active,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      createdOn: DateTime.parse(json['createdOn']),
      expiredOn: DateTime.parse(json['expiredOn']),
      active: json['active'] ?? false,
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'createdOn': createdOn.toIso8601String(),
      'expiredOn': expiredOn.toIso8601String(),
      'active': active,
      'user': user.toJson(),
    };
  }
}