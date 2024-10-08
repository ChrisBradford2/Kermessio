import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TombolaStatusPage extends StatefulWidget {
  final int kermesseId;
  final int userId;
  final String token;

  const TombolaStatusPage({required this.kermesseId, required this.userId, required this.token, super.key});

  @override
  TombolaStatusPageState createState() => TombolaStatusPageState();
}

class TombolaStatusPageState extends State<TombolaStatusPage> {
  bool isLoading = true;
  bool isWinner = false;
  bool isDrawn = false;
  String? prize;
  String? statusMessage;

  @override
  void initState() {
    super.initState();
    _fetchTombolaStatus();
  }

  Future<void> _fetchTombolaStatus() async {
    try {
      final response = await http.get(
          Uri.parse('${AppConfig().baseUrl}/tombola/${widget.kermesseId}/status/${widget.userId}'
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data);
        }
        setState(() {
          isWinner = data['is_winner'] ?? false;
          isDrawn = data['is_drawn'] ?? false;
          prize = data['prize'];
          statusMessage = !isDrawn ? data['message'] : (isWinner ? 'Félicitations ! Vous avez gagné : $prize' : 'Désolé, vous n\'avez pas gagné cette fois-ci.');
          isLoading = false;
        });
      } else {
        setState(() {
          statusMessage = 'Erreur lors de la récupération du statut de la tombola : ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Erreur lors de la récupération du statut de la tombola : $e';
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statut de la Tombola'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  statusMessage ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!isWinner && isDrawn)
              const Center(
                child: Text(
                  'Merci d\'avoir participé. Bonne chance pour la prochaine fois !',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            if (isWinner && prize != null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
                    const SizedBox(height: 20),
                    Text(
                      'Félicitations ! Vous avez gagné :',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      prize!,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
