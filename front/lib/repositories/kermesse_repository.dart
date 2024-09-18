import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kermesse_model.dart';

class KermesseRepository {
  final String? baseUrl;
  final String token;

  KermesseRepository({required this.baseUrl, required this.token});

  Future<List<Kermesse>> getKermesses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/kermesses'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['kermesses'];
      print("Kermesses: $data");
      return data.map((json) => Kermesse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load kermesses');
    }
  }
}
