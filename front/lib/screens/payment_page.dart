import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/stripe_service.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Stripe'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              // Créer un PaymentIntent via le backend
              final clientSecret = await StripeService.createPaymentIntent(1000, 'usd');  // Exemple : 1000 centimes = 10 USD

              // Initialiser Stripe avec le client secret
              await Stripe.instance.initPaymentSheet(
                paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: clientSecret,
                  applePay: const PaymentSheetApplePay(
                    merchantCountryCode: 'FR',
                  ),
                  googlePay: const PaymentSheetGooglePay(
                    merchantCountryCode: 'FR',
                    testEnv: true,
                  ),
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Kermessio',
                ),
              );

              await Stripe.instance.presentPaymentSheet();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paiement réussi !')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur lors du paiement : $e')),
              );
            }
          },
          child: const Text('Payer avec Stripe'),
        ),
      ),
    );
  }
}
