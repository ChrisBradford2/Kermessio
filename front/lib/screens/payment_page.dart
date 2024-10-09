import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/stripe_service.dart';
import '../blocs/kermesse_bloc.dart';
import '../blocs/kermesse_state.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Stripe'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _handlePayment,
          child: const Text('Payer avec Stripe'),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
    });

    print('Paiement en cours...');
    try {
      final kermesseState = BlocProvider.of<KermesseBloc>(context).state;
      if (kermesseState is KermesseSelected) {
        final int kermesseId = kermesseState.kermesseId;
        if (kDebugMode) {
          print('Kermesse ID: $kermesseId');
        } // Log important pour vérifier l'ID

        // Créer un PaymentIntent via le backend en passant l'ID de la kermesse
        final clientSecret = await StripeService.createPaymentIntent(1000, 'eur', kermesseId);
        if (kDebugMode) {
          print('Client secret obtenu: $clientSecret');
        } // Log important pour vérifier que le PaymentIntent est bien créé

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
        if (kDebugMode) {
          print('Initialisation du PaymentSheet réussie');
        } // Log pour valider l'initialisation

        await Stripe.instance.presentPaymentSheet();
        if (kDebugMode) {
          print('Paiement réalisé avec succès');
        } // Log après la présentation du PaymentSheet

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement réussi !')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune kermesse sélectionnée')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du paiement: $e');
      } // Log pour capturer l'erreur
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du paiement : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
