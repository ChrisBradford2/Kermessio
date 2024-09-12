import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeService {
  static Future<String> createPaymentIntent(int amount, String currency) async {
    final url = Uri.parse('http://10.0.2.2:8080/create-payment-intent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': amount,
        'currency': currency,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['clientSecret'];
    } else {
      throw Exception('Erreur lors de la création du PaymentIntent');
    }
  }
}
