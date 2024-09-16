import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/participation_model.dart';

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

  Future<List<Participation>> fetchParticipationsByActivity(int activityId) async {
    final url = Uri.parse('$baseUrl/activities/$activityId/participations');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      List<dynamic> data = responseBody['participations'];
      return data.map((participationJson) => Participation.fromJson(participationJson)).toList();
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Erreur lors de la récupération des participations');
    }
  }

  Future<bool> updateParticipation(int participationId, bool isWinner) async {
    final url = Uri.parse('$baseUrl/participations/$participationId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'participation_id': participationId,
        'is_winner': isWinner,
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
