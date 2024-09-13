import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
}
