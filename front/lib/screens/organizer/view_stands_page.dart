import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';

class ViewStandsPage extends StatefulWidget {
  const ViewStandsPage({super.key});

  @override
  ViewStandsPageState createState() => ViewStandsPageState();
}

class ViewStandsPageState extends State<ViewStandsPage> {
  List<dynamic> _stands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStands();
  }

  Future<void> _fetchStands() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;
      final url = '${AppConfig().baseUrl}/user/organizer/stands';

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _stands = data['stands'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la récupération des stands')),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _stands.length,
          itemBuilder: (context, index) {
            final stand = _stands[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ExpansionTile(
                  leading: const Icon(Icons.store, color: Colors.red, size: 32),
                  title: Text(
                    'Stand: ${stand['username']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Stock total : ${stand['stocks'].length} articles',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  children: stand['stocks'].map<Widget>((stock) {
                    return ListTile(
                      leading: const Icon(Icons.fastfood, color: Colors.green),
                      title: Text('Article: ${stock['item_name']}',
                          style: const TextStyle(fontSize: 16)),
                      subtitle: Text(
                        'Quantité: ${stock['quantity']} | Prix: ${stock['price']} jetons',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
