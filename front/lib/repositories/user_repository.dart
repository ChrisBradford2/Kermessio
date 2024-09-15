import 'dart:convert';
import 'package:http/http.dart' as http;

class UserRepository {
  final String baseUrl = "http://10.0.2.2:8080";

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