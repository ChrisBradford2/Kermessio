import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';

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
                setState(() {
                  _selectedAmount = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                _initiatePayment(context, _selectedAmount * 100); // 1€ = 100 centimes
              },
              child: const Text("Payer"),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour initier le paiement en appelant l'API backend
  Future<void> _initiatePayment(BuildContext context, int amount) async {
    setState(() {
      _isLoading = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être authentifié pour acheter des tokens')),
      );
      return;
    }

    final String token = authState.token;

    try {
      // Appel à l'API backend pour créer le PaymentIntent
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/create-payment-intent'), // Adresse du backend
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amount, // En centimes (Stripe fonctionne en centimes)
          'currency': 'eur',
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (kDebugMode) {
        print('Response: ${response.body}');
      }

      if (response.statusCode == 200 && jsonResponse['clientSecret'] != null) {
        final clientSecret = jsonResponse['clientSecret'];

        await _confirmPayment(context, clientSecret);
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du paiement : $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Confirmer le paiement et rediriger vers la page d'accueil
  Future<void> _confirmPayment(BuildContext context, String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        style: ThemeMode.system,
        merchantDisplayName: 'Kermessio',
      ));

      // Afficher le PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // Paiement réussi, afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement réussi ! Vos jetons ont été ajoutés.')),
      );

      // Rediriger vers la page d'accueil après le paiement
      Navigator.pushReplacementNamed(context, '/home');

      // Mettre à jour les tokens après le paiement en déclenchant un événement
      context.read<AuthBloc>().add(AuthRefreshRequested()); // Déclencher la mise à jour des tokens
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du paiement : $e')),
      );
    }
  }
}
