import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ChildRepository {
  final String apiUrl = 'http://10.0.2.2:8080';

  Future<bool> createChildAccount({
    required String username,
    required String password,
    required String token,  // Parent's authentication token
  }) async {
    final url = Uri.parse('$apiUrl/user/child');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Token to authenticate the parent
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return true;  // Account successfully created
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
      } // Log the error details
      return false;  // Failed to create the account
    }
  }

  // Correction de la méthode getChildren pour qu'elle renvoie une liste de User
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
        final List<dynamic> childrenJson = json.decode(response.body);
        return childrenJson.map((json) => User.fromJson(json)).toList();
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

  // Méthode pour attribuer des jetons à un enfant
  Future<bool> assignTokensToChild({
    required String childId,
    required int tokens,
    required String token,  // Parent's authentication token
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
