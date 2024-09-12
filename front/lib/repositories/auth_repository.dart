import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthRepository {
  final String baseUrl = "http://10.0.2.2";

  Future<UserWithToken> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserWithToken(
        user: User.fromJson(data['user']),
        token: data['token'],  // Assure-toi que le token est renvoyé par l'API
      );
    } else {
      throw Exception("Erreur de connexion");
    }
  }

  Future<UserWithToken> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      body: {'username': username, 'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserWithToken(
        user: User.fromJson(data['user']),
        token: data['token'],  // Assure-toi que le token est renvoyé par l'API
      );
    } else {
      throw Exception("Erreur d'inscription");
    }
  }
}

// New class to hold both the user and token
class UserWithToken {
  final User user;
  final String token;

  UserWithToken({required this.user, required this.token});
}
