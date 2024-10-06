import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/school_model.dart';

class SchoolRepository {
  final String token;

  SchoolRepository({required this.token});

  Future<List<School>> getSchools() async {
    final url = '${AppConfig().baseUrl}/schools';

    if (kDebugMode) {
      print('token: $token');
    }

    try {
      final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          }
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Vérifier si la réponse contient une clé "schools"
        if (data.containsKey('schools')) {
          final List<dynamic> schoolList = data['schools'];
          if (kDebugMode) {
            print('schoolList: $schoolList');
          }
          return schoolList.map((school) => School.fromJson(school)).toList();
        } else {
          throw Exception('Clé "schools" non trouvée dans la réponse');
        }
      } else {
        throw Exception('Erreur lors de la récupération des écoles');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des écoles : $e');
      }
      throw Exception('Erreur lors de la récupération des écoles : $e');
    }
  }

  // Ajouter une nouvelle école (exemple)
  Future<void> addSchool(School school) async {
    final url = '${AppConfig().baseUrl}/schools';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(school.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout de l\'école');
    }
  }
}
