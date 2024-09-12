class User {
  final String id;
  final String username;
  final String email;
  final String role;

  User({required this.id,
    required this.username,
    required this.email,
    required this.role
  });

  // Method to convert a JSON object to a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}
