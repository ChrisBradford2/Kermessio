import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';

class StockRepository {
  final String? baseUrl;
  final String token;

  StockRepository({this.baseUrl, required this.token});

  // Create a stock
  Future<Stock?> createStock(Stock stock, int kermesseId) async {
    final url = Uri.parse('$baseUrl/stocks');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        ...stock.toJson(),
        'kermesse_id': kermesseId,
      }),
    );

    if (response.statusCode == 200) {
      return Stock.fromJson(jsonDecode(response.body));
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Erreur lors de la création du stock');
    }
  }

  // Fetch all stocks
  Future<List<Stock>> fetchStocks() async {
    final url = Uri.parse('$baseUrl/stocks');
    if (kDebugMode) {
      print('Fetching stocks from $url');
    }
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      List<dynamic> data = responseBody['data'];
      return data.map((stockJson) => Stock.fromJson(stockJson)).toList();
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Erreur lors du chargement des stocks');
    }
  }

  // Fetch all stocks with optional pagination
  Future<List<Stock>> fetchAllStocks({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl/stocks/all?page=$page&limit=$limit');
    if (kDebugMode) {
      print('Fetching stocks from $url');
    }
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      List<dynamic> data = responseBody['data'];
      if (kDebugMode) {
        print(data);
      }
      return data.map((stockJson) => Stock.fromJson(stockJson)).toList();
    } else {
      if (kDebugMode) {
        print("Error: ${response.statusCode} - ${response.body}");
      }
      throw Exception('Erreur lors du chargement des stocks');
    }
  }

  Future<bool> buyStock(int stockId, int boothHolderId) async {
    final url = Uri.parse('$baseUrl/stocks/buy');
    final body = jsonEncode({
      'stock_id': stockId,
      'booth_holder_id': boothHolderId,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Achat réussi : ${response.body}");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Erreur lors de l'achat : ${response.statusCode} - ${response.body}");
      }
      return false;
    }
  }
}
