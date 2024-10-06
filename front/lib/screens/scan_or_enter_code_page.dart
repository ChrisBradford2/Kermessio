import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/config/app_config.dart';
import 'package:front/blocs/auth_bloc.dart';
import 'package:front/blocs/auth_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanAndValidateOrderPage extends StatefulWidget {
  const ScanAndValidateOrderPage({super.key});

  @override
  ScanAndValidateOrderPageState createState() => ScanAndValidateOrderPageState();
}

class ScanAndValidateOrderPageState extends State<ScanAndValidateOrderPage> {
  final TextEditingController _codeController = TextEditingController();
  String? _message;
  Map<String, dynamic>? _orderData;

/*
  Future<void> _scanQRCode() async {
    String scannedCode;
    try {
      scannedCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Couleur du bouton de scan
        'Annuler', // Texte du bouton d'annulation
        true,      // Afficher le flash
        ScanMode.QR,
      );
      if (scannedCode != '-1') {
        _validateCode(scannedCode);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scanning code: $e');
      }
      setState(() {
        _message = 'Erreur lors du scan';
      });
    }
  }
 */

  // Fonction pour valider le code scanné ou entré et afficher la commande
  Future<void> _validateCode(String code) async {
    try {
      final authState = BlocProvider.of<AuthBloc>(context).state;

      if (authState is AuthAuthenticated) {
        final token = authState.token;
        final url = AppConfig().baseUrl;

        // Envoyer une requête pour vérifier si le code est valide et récupérer les détails de la commande
        final response = await http.post(
          Uri.parse('$url/purchases/verify'), // Route de vérification du code
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'code': code}),
        );

        if (response.statusCode == 200) {
          final orderData = jsonDecode(response.body);
          if (kDebugMode) {
            print (orderData);
          }
          setState(() {
            _orderData = orderData;
            _message = null;
          });
        } else {
          setState(() {
            _message = 'Code invalide';
            _orderData = null;
          });
        }
      } else {
        setState(() {
          _message = 'Vous devez être authentifié pour valider un code';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erreur lors de la validation';
      });
    }
  }

  // Fonction pour valider la commande une fois le code validé
  Future<void> _validateOrder() async {
    if (_orderData != null) {
      try {
        final authState = BlocProvider.of<AuthBloc>(context).state;

        if (authState is AuthAuthenticated) {
          final token = authState.token;
          final url = AppConfig().baseUrl;

          final response = await http.post(
            Uri.parse('$url/purchases/validate'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'purchaseId': _orderData!['id']}),
          );

          if (!mounted) return;

          if (response.statusCode == 200) {
            Navigator.pop(context, 'Commande validée avec succès');
          } else {
            setState(() {
              _message = 'Erreur lors de la validation de la commande';
            });
          }
        }
      } catch (e) {
        setState(() {
          _message = 'Erreur lors de la validation de la commande';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner ou entrer un code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: null,
              child: const Text('Scanner un QR code'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Entrer le code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _validateCode(_codeController.text);
              },
              child: const Text('Valider le code'),
            ),
            const SizedBox(height: 20),

            if (_orderData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Article: ${_orderData!['stock']['item_name']}'),
                  Text('Quantité: ${_orderData!['quantity']}'),
                  Text('Prix: ${_orderData!['price']} jetons'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _validateOrder,
                    child: const Text('Valider la commande'),
                  ),
                ],
              ),

            if (_message != null)
              Text(
                _message!,
                style: const TextStyle(color: Colors.green, fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
