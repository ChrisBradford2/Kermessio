import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/purchase_model.dart';

class PurchaseRepository {
  final String? baseUrl;
  final String token;

  PurchaseRepository({required this.baseUrl, required this.token});

  Future<List<Purchase>> fetchPurchasesByUser(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/purchases');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body)['purchases'];
      return body.map((purchaseJson) => Purchase.fromJson(purchaseJson)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to load purchases');
    }
  }
}