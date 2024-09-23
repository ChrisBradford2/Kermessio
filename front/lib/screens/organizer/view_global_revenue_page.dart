import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';

class ViewGlobalRevenuePage extends StatefulWidget {
  final int kermesseId;  // Ajout du kermesseId comme paramètre

  const ViewGlobalRevenuePage({super.key, required this.kermesseId});

  @override
  ViewGlobalRevenuePageState createState() => ViewGlobalRevenuePageState();
}

class ViewGlobalRevenuePageState extends State<ViewGlobalRevenuePage> {
  int _totalRevenue = 0;
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGlobalRevenue();
  }

  Future<void> _fetchGlobalRevenue() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;
      final url = '${AppConfig().baseUrl}/user/organizer/${widget.kermesseId}/revenue';  // Utilisation du kermesseId passé

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _totalRevenue = data['total_revenue'];
            _transactions = data['transactions'];  // Récupérer la liste des transactions
            _isLoading = false;
          });
        } else {
          if (kDebugMode) {
            print('Error fetching global revenue: ${response.statusCode} - ${response.body}');
          }
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la récupération des recettes globales')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non authentifié')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 30, color: Colors.teal),
                    const SizedBox(width: 10),
                    Text(
                      'Jetons achetés : $_totalRevenue',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 30, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(
                      'Recettes : $_totalRevenue €',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Historique des transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.receipt, color: Colors.teal),
                    title: Text('Transaction ID: ${transaction['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jetons achetés: ${transaction['tokens']}'),
                        Text('Date: ${transaction['createdAt'] ?? "Inconnue"}'), // Assurez-vous d'ajouter une date au backend si possible
                      ],
                    ),
                    trailing: Text(
                      '${transaction['amount']} €',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
