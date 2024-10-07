import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_model.dart';

class ChildRepository {
  final String? apiUrl = AppConfig().baseUrl;

  Future<bool> createChildAccount({
    required String username,
    required String firstName,
    required String lastName,
    required String password,
    required String token,
  }) async {
    final url = Uri.parse('$apiUrl/user/child');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Non autorisé');
    } else if (response.statusCode == 403) {
      throw Exception('Interdit');
    } else if (response.statusCode == 404) {
      throw Exception('Non trouvé');
    } else {
      if (kDebugMode) {
        print("Token: $token");
        print("Error: ${response.statusCode} - ${response.body}");
      }
      return false;
    }
  }

  Future<List<User>> getChildren(String token) async {
    final url = Uri.parse('$apiUrl/user/child');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }

    if (response.statusCode == 200) {
      try {
        if (response.body.isNotEmpty) {
          final List<dynamic> childrenJson = json.decode(response.body);
          return childrenJson.map((json) => User.fromJson(json)).toList();
        } else {
          return [];
        }
      } catch (e) {
        if (kDebugMode) {
          print("Erreur lors du décodage du JSON : $e");
        }
        throw Exception('Erreur lors du traitement des données');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Non autorisé');
    } else if (response.statusCode == 403) {
      throw Exception('Interdit');
    } else if (response.statusCode == 404) {
      throw Exception('Non trouvé');
    } else {
      if (kDebugMode) {
        print("Token: $token");
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Échec de la récupération des enfants');
    }
  }

  Future<bool> assignTokensToChild({
    required String childId,
    required int tokens,
    required String token,
  }) async {
    final url = Uri.parse('$apiUrl/user/child/$childId/tokens');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tokens': tokens,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      if (kDebugMode) {
        print("Authorization Token: Bearer $token");
        print("Error: ${response.statusCode} - ${response.body}");
        print(response.headers);
      }
      throw Exception('Non autorisé');
    } else if (response.statusCode == 403) {
      throw Exception('Interdit');
    } else if (response.statusCode == 404) {
      throw Exception('Enfant non trouvé');
    } else {
      if (kDebugMode) {
        print("Token: $token");
        print("Error: ${response.statusCode} - ${response.body}");
      }
      return false;
    }
  }
}
