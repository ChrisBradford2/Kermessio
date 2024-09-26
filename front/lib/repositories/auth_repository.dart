import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class AuthRepository {
  final String? baseUrl = AppConfig().baseUrl;

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

  Future<String> register(
    String username,
    String lastName,
    String firstName,
    String email,
    String password,
    String role,
    int schoolId,
  ) async {
    if (kDebugMode) {
      print('Tentative d\'inscription avec :');
      print(
          'Username: $username, Email: $email, Password: $password, Role: $role, First Name: $firstName, Last Name: $lastName, School ID: $schoolId');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'first_name': firstName,
        'last_name': lastName,
        'school_id': schoolId,
      }),
    );

    if (kDebugMode) {
      print('Réponse de l\'API: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'];
    } else if (response.statusCode == 409) {
      throw Exception("Le nom d'utilisateur ou l'email existe déjà.");
    } else {
      throw Exception("Erreur d'inscription");
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // Utiliser le token pour authentifier la requête
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'user': data['user'],
        // Assure-toi que le backend renvoie bien un objet "user"
      };
    } else {
      throw Exception(
          "Erreur lors de la récupération des informations de l'utilisateur");
    }
  }
}
