import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';

class TombolaManagementPage extends StatefulWidget {
  final int kermesseId;

  const TombolaManagementPage({super.key, required this.kermesseId});

  @override
  _TombolaManagementPageState createState() => _TombolaManagementPageState();
}

class _TombolaManagementPageState extends State<TombolaManagementPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _tombolaData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTombolaData();
  }

  Future<void> _fetchTombolaData() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;

      final url = '${AppConfig().baseUrl}/tombola/${widget.kermesseId}';
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _tombolaData = json.decode(response.body);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Erreur lors de la récupération des données de la tombola';
            _isLoading = false;
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Une erreur s\'est produite : $error';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Utilisateur non authentifié';
        _isLoading = false;
      });
    }
  }

  void _drawTombola() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tirage de la tombola effectué !'),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tombolaData != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lots de la tombola :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_tombolaData!['prizes'] is String)
              Text(_tombolaData!['prizes'])
            else if (_tombolaData!['prizes'] is List &&
                _tombolaData!['prizes'].isEmpty)
              const Text('Aucun lot pour cette tombola.')
            else
              ..._tombolaData!['prizes'].map<Widget>((prize) {
                return ListTile(
                  title: Text(prize['name']),
                  subtitle: Text('Valeur : ${prize['value']}'),
                );
              }).toList(),
            const SizedBox(height: 30),
            const Text(
              'Participants inscrits :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_tombolaData!['participants'] != null &&
                _tombolaData!['participants'].isNotEmpty)
              ..._tombolaData!['participants'].map<Widget>((participant) {
                return ListTile(
                  title: Text(participant['username']),
                );
              }).toList()
            else
              const Text('Aucun participant pour cette tombola.'),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _drawTombola,
                child: const Text('Faire le tirage'),
              ),
            ),
          ],
        ),
      )
          : Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      ),
    );
  }
}
