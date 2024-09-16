import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/activity_model.dart';

class ActivityRepository {
  final String baseUrl;
  final String token;

  ActivityRepository({required this.baseUrl, required this.token});

  // Create an activity
  Future<Activity?> createActivity(Activity activity) async {
    final url = Uri.parse('$baseUrl/activities');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(activity.toJson()),
    );

    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body)['activity']);
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Erreur lors de la création de l\'activité');
    }
  }

  Future<List<Activity>> fetchActivities() async {
    final url = Uri.parse('$baseUrl/activities');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> activitiesData = jsonResponse['activities'];

      // On convertit chaque activité en instance de Activity
      return activitiesData.map((activityJson) => Activity.fromJson(activityJson)).toList();
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Erreur lors du chargement des activités');
    }
  }

  Future<Activity> getActivityById(int id) async {
    final url = Uri.parse('$baseUrl/activities/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du chargement de l\'activité');
    }
  }

  Future<Activity?> updateActivity(Activity activity) async {
    final url = Uri.parse('$baseUrl/activities/${activity.id}');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(activity.toJson()),
    );

    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de l\'activité');
    }
  }

  Future<void> deleteActivity(int id) async {
    final url = Uri.parse('$baseUrl/activities/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de l\'activité');
    }
  }
}
