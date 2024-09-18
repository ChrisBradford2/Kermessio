import 'package:http/http.dart' as http;
import 'dart:convert';

class TombolaRepository {
  final String? baseUrl;
  final String token;

  TombolaRepository({
    required this.baseUrl,
    required this.token,
  });

  // Méthode pour acheter un ticket de tombola
  Future<Map<String, dynamic>> buyTicket(int userId, String userRole, int kermesseId) async {
    final url = '$baseUrl/tombola/buy';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'role': userRole,
        'kermesse_id': kermesseId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Erreur lors de l\'achat du ticket de tombola : ${response.statusCode} - ${response.body}');
      throw Exception('Erreur lors de l\'achat du ticket de tombola : ${response.body}');
    }
  }
}
