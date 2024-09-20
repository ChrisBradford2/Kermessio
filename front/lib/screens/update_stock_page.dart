import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';

class UpdateStockPage extends StatefulWidget {
  final Map<String, dynamic> stock;

  const UpdateStockPage({super.key, required this.stock});

  @override
  UpdateStockPageState createState() => UpdateStockPageState();
}

class UpdateStockPageState extends State<UpdateStockPage> {
  final TextEditingController _quantityController = TextEditingController();
  String? _message;

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.stock['quantity'].toString();
  }

  Future<void> _updateQuantity() async {
    try {
      final authState = BlocProvider.of<AuthBloc>(context).state;

      if (authState is AuthAuthenticated) {
        final token = authState.token;
        final url = AppConfig().baseUrl;

        final response = await http.put(
          Uri.parse('$url/stocks/update'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'stockId': widget.stock['id'],
            'quantity': int.parse(_quantityController.text),
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _message = 'Quantité mise à jour avec succès';
          });
          Navigator.pop(context, 'Quantité mise à jour avec succès');
        } else {
          setState(() {
            _message = 'Erreur lors de la mise à jour de la quantité';
          });
        }
      } else {
        setState(() {
          _message = 'Utilisateur non authentifié';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erreur lors de la mise à jour';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mettre à jour la quantité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Article : ${widget.stock['item_name']}'),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantité',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateQuantity,
              child: const Text('Mettre à jour la quantité'),
            ),
            if (_message != null)
              Text(
                _message!,
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
