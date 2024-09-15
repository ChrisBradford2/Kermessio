import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';

class StockRepository {
  final String baseUrl;
  final String token;

  StockRepository({required this.baseUrl, required this.token});

  // Create a stock
  Future<Stock?> createStock(Stock stock) async {
    final url = Uri.parse('$baseUrl/stocks');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(stock.toJson()),
    );

    if (response.statusCode == 200) {
      return Stock.fromJson(jsonDecode(response.body));
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      throw Exception('Erreur lors de la création du stock');
    }
  }

  // Fetch all stocks
  Future<List<Stock>> fetchStocks() async {
    final url = Uri.parse('$baseUrl/stocks');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((stockJson) => Stock.fromJson(stockJson)).toList();
    } else {
      throw Exception('Erreur lors du chargement des stocks');
    }
  }
}
