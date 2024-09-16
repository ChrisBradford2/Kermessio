import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class UserRepository {
  final String? baseUrl = AppConfig().baseUrl;

  Future<Map<String, dynamic>> getUserDetails(String token) async {
    final url = Uri.parse('$baseUrl/user/me');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user details');
    }
  }

}