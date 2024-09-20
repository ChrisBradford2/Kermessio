import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/blocs/auth_bloc.dart';
import 'package:front/blocs/auth_state.dart';
import 'package:front/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class InteractiveMapPage extends StatefulWidget {
  const InteractiveMapPage({super.key});

  @override
  InteractiveMapPageState createState() => InteractiveMapPageState();
}

class InteractiveMapPageState extends State<InteractiveMapPage> {
  List<dynamic> _stands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStands();
  }

  Future<void> _fetchStands() async {
    final authState = context.read<AuthBloc>().state; // Récupérer l'état d'authentification
    if (authState is! AuthAuthenticated) {
      // Si l'utilisateur n'est pas authentifié, montrer un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être authentifié')),
      );
      return;
    }

    final token = authState.token; // Récupérer le token d'authentification
    final url = '${AppConfig().baseUrl}/user/organizer/stands';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Ajouter le token dans l'en-tête
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stands = data['stands'];
          _isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print('Error fetching stands: ${response.statusCode} - ${response.body}');
        }
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

  Offset _generateRandomPosition(Size canvasSize) {
    final random = Random();

    const minX = 50.0;
    final maxX = canvasSize.width - 50;

    const minY = 150.0;
    final maxY = canvasSize.height - 150;

    final x = minX + random.nextInt((maxX - minX).toInt()).toDouble();
    final y = minY + random.nextInt((maxY - minY).toInt()).toDouble();

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/map_background.webp',
              fit: BoxFit.cover,
            ),
          ),
          ..._stands.map((stand) {
            final position = _generateRandomPosition(MediaQuery.of(context).size);
            return Positioned(
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                onTap: () {
                  // Afficher plus de détails sur le stand
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Stand: ${stand['username']}'),
                      content: Text('Tenu par: ${stand['username']}'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),  // Espacement autour de l'icône
                  decoration: BoxDecoration(
                    color: Colors.white,  // Fond blanc
                    shape: BoxShape.circle,  // Forme circulaire
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),  // Ombre légère
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 32.0,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
