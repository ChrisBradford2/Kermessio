import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class StripeService {
  static Future<String> createPaymentIntent(int amount, String currency, int kermesseId) async {
    if (kDebugMode) {
      print('Envoi de la requête avec kermesse_id: $kermesseId');
    }
    final String? baseUrl = AppConfig().baseUrl;
    final url = Uri.parse('$baseUrl/create-payment-intent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': amount,
        'currency': currency,
        'kermesse_id': kermesseId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (kDebugMode) {
        print('PaymentIntent créé: $jsonResponse');
      }

      return jsonResponse['clientSecret'];
    } else {
      throw Exception('Erreur lors de la création du PaymentIntent');
    }
  }
}
