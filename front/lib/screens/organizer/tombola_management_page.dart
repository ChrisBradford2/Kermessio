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
  TombolaManagementPageState createState() => TombolaManagementPageState();
}

class TombolaManagementPageState extends State<TombolaManagementPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _tombolaData;
  String _errorMessage = '';
  String? _winner;
  bool _isDrawn = false;

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
          print(response.body);
          setState(() {
            _tombolaData = json.decode(response.body);
            _isDrawn = _tombolaData!['drawn'];
            _winner = _tombolaData!['winner'];
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

  Future<void> _drawTombola() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;
      final url = '${AppConfig().baseUrl}/tombola/${widget.kermesseId}/draw';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            _winner = responseData['winner']['username'];
            _isDrawn = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Le gagnant est : ${_winner!}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Erreur lors du tirage de la tombola';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : $_errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Une erreur s\'est produite : $error';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            else if (_tombolaData!['prizes'] is List && _tombolaData!['prizes'].isEmpty)
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
            if (_tombolaData!['participants'] != null && _tombolaData!['participants'].isNotEmpty)
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
                onPressed: _isDrawn
                    ? null
                    : _drawTombola,
                child: Text(_isDrawn ? 'Tombola déjà tirée' : 'Faire le tirage'),
              ),
            ),
            if (_winner != null) ...[
              const SizedBox(height: 30),
              Text('Gagnant de la tombola : $_winner',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
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
