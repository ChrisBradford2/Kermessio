import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ParticipationRepository {
  final String? baseUrl;
  final String token;

  ParticipationRepository({required this.baseUrl, required this.token});

  Future<bool> participateInActivity(int activityId, int userId) async {
    final url = Uri.parse('$baseUrl/participations');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'activity_id': activityId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      return false;
    }
  }
}
