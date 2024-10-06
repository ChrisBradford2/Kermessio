class User {
  final int id;
  final String username;
  final String email;
  final String role;
  int tokens;
  final int points;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.tokens,
    required this.points,
  });

  // Method to convert a JSON object to a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      tokens: json['tokens'] ?? 0,
      points: json['points'] ?? 0,
    );
  }
}
