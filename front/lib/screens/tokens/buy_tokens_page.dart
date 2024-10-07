import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/kermesse_bloc.dart';
import '../../blocs/kermesse_state.dart';
import '../../config/app_config.dart';

class BuyTokensPage extends StatefulWidget {
  const BuyTokensPage({super.key});

  @override
  BuyTokensPageState createState() => BuyTokensPageState();
}

class BuyTokensPageState extends State<BuyTokensPage> {
  int _selectedAmount = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acheter des tokens"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sélectionnez le montant pour acheter des tokens",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: _selectedAmount,
              items: [1, 5, 10, 20, 50, 100].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value €"),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedAmount = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                _initiatePayment(_selectedAmount * 100); // 1€ = 100 centimes
              },
              child: const Text("Payer"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initiatePayment(int amount) async {
    setState(() {
      _isLoading = true;
    });

    final authState = context.read<AuthBloc>().state;
    final kermesseState = context.read<KermesseBloc>().state;

    if (authState is! AuthAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être authentifié pour acheter des tokens')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (kermesseState is! KermesseSelected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une kermesse')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String token = authState.token;
    final int kermesseId = kermesseState.kermesseId;

    try {
      final baseUrl = AppConfig().baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amount,
          'currency': 'eur',
          'kermesseId': kermesseId,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (kDebugMode) {
        print('Response: ${response.body}');
      }

      if (response.statusCode == 200 && jsonResponse['clientSecret'] != null) {
        final clientSecret = jsonResponse['clientSecret'];
        await _confirmPayment(clientSecret);
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du paiement : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmPayment(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        style: ThemeMode.system,
        merchantDisplayName: 'Kermessio',
      ));

      await Stripe.instance.presentPaymentSheet();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement réussi ! Vos jetons ont été ajoutés.')),
        );

        Navigator.pushReplacementNamed(context, '/');

        context.read<AuthBloc>().add(AuthRefreshRequested()); // Déclencher la mise à jour des tokens
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du paiement : $e')),
        );
      }
    }
  }
}
