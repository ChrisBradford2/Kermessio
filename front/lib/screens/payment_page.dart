import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/stripe_service.dart';
import '../blocs/kermesse_bloc.dart';
import '../blocs/kermesse_state.dart';

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
              // Obtenir l'ID de la kermesse depuis le KermesseBloc
              final kermesseState = BlocProvider.of<KermesseBloc>(context).state;
              if (kermesseState is KermesseSelected) {
                final int kermesseId = kermesseState.kermesseId;

                // Créer un PaymentIntent via le backend en passant l'ID de la kermesse
                final clientSecret = await StripeService.createPaymentIntent(1000, 'eur', kermesseId);

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
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aucune kermesse sélectionnée')),
                );
              }
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
