import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl = "http://10.0.2.2:8080";

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'username': username, 'password': password}),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      print(response.body);
      throw Exception("Erreur de connexion");
    }
  }

  Future<String> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'username': username, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      print(response.body);
      throw Exception("Erreur d'inscription");
    }
  }
}
