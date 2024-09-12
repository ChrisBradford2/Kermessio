import 'dart:convert';
import 'package:http/http.dart' as http;

class ChildRepository {
  final String apiUrl = 'https://your-api-url.com';

  Future<bool> createChildAccount({
    required String username,
    required String password,
    required String token,  // Parent's authentication token
  }) async {
    final url = Uri.parse('$apiUrl/create-child');
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
    } else {
      return false;  // Failed to create the account
    }
  }
}
