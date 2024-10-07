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
            print(orderData);
          }
          setState(() {
            _orderData = orderData;
            if (_orderData!['status'] == 'approved') {
              _message = 'Erreur : cette commande a déjà été validée';
              _orderData = null;
            } else {
              _message = null;
            }
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
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: null,
              child: const Text('Scanner un QR code', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Entrer le code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _codeController.text = _codeController.text.toUpperCase();
                _validateCode(_codeController.text);
              },
              child: const Text('Valider le code', style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
              )),
            ),
            const SizedBox(height: 20),
            if (_orderData != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Article: ${_orderData!['stock']['item_name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Quantité: ${_orderData!['quantity']}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Prix: ${_orderData!['price']} jetons', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _validateOrder,
                        child: const Text('Valider la commande', style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _message == 'Code invalide' ? Colors.red : Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
