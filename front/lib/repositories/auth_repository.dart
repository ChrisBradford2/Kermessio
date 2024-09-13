import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl = "http://10.0.2.2:8080";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'username': username, 'password': password}),
    );

    if (kDebugMode) {
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (kDebugMode) {
        print('Decoded data: $data');
      }

      return {
        'user': data['user'],
        'token': data['token'],
      };
    } else {
      if (kDebugMode) {
        print(response.body);
      }
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
      return data['message'];  // Return the success message
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      throw Exception("Erreur d'inscription");
    }
  }
}
