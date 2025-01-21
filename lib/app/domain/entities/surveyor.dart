class Surveyor {
  final String name;
  final String role;
  final String avatarUrl;
  final double balance;
  final int responses;
  final double growthRate;

  Surveyor({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.balance,
    required this.responses,
    required this.growthRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
      'balance': balance,
      'responses': responses,
      'growthRate': growthRate,
    };
  }
}