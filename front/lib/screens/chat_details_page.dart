import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:http/http.dart' as http;

import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';

class ChatDetailsPage extends StatefulWidget {
  final int boothHolderId;
  final String boothHolderUsername;

  const ChatDetailsPage({
    super.key,
    required this.boothHolderId,
    required this.boothHolderUsername,
  });

  @override
  ChatDetailsPageState createState() => ChatDetailsPageState();
}

class ChatDetailsPageState extends State<ChatDetailsPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<dynamic> _messages = [];
  bool _isLoading = true;
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();

    // Initier la connexion WebSocket
    final wsUrl = 'ws://10.0.2.2:8080/ws';  // Remplacer par l'URL du serveur WebSocket
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // Récupérer les messages existants depuis l'API
    _fetchMessages();

    // Écouter les messages en temps réel via WebSocket
    _channel.stream.listen((message) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;  // Récupérer l'état d'authentification ici

      setState(() {
        final decodedMessage = jsonDecode(message);

        // Si l'information sur le Sender est manquante, la compléter avec l'utilisateur authentifié
        if (decodedMessage['Sender'] == null && authState is AuthAuthenticated) {
          decodedMessage['Sender'] = {
            'id': authState.user.id,
            'username': authState.user.username,  // Ajouter ton username si manquant
          };
        }

        // Ajouter le message avec les informations correctes à la liste
        _messages.add(decodedMessage);

        _isLoading = false;  // Arrêter le spinner après réception du premier message
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);  // Fermer la connexion WebSocket
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final senderId = authState.user.id;  // Récupérer l'ID de l'utilisateur actuel
      final receiverId = widget.boothHolderId;  // ID du booth holder

      try {
        // Appel à l'API pour récupérer l'historique des messages
        final response = await http.get(
          Uri.parse('https://kermessio.xyz/chat/messages?sender_id=$senderId&receiver_id=$receiverId'),
          headers: {
            'Authorization': 'Bearer ${authState.token}',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Messages: $data');

          setState(() {
            _messages.addAll(data['messages']);  // Ajouter les messages récupérés à la liste
            _isLoading = false;  // Désactiver le spinner
          });
        } else {
          print('Error fetching messages: ${response.statusCode} - ${response.body}');
          setState(() {
            _isLoading = false;  // Désactiver le spinner même en cas d'erreur
          });
        }
      } catch (e) {
        print('Error fetching messages: $e');
        setState(() {
          _isLoading = false;  // Désactiver le spinner en cas d'erreur
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non authentifié')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final senderId = authState.user.id;
      final messageText = _messageController.text;

      if (messageText.isEmpty) return;

      // Préparer le message à envoyer
      final message = {
        'sender_id': senderId,
        'receiver_id': widget.boothHolderId,
        'message': messageText,
      };

      // Envoyer le message via WebSocket
      _channel.sink.add(jsonEncode(message));

      // Vider le champ de texte après envoi
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final user = authState.user;
      final boothHolderUsername = widget.boothHolderUsername;

      return Scaffold(
        appBar: AppBar(
          title: Text('Chat avec $boothHolderUsername'),
        ),
        body: Column(
          children: <Widget>[
            _isLoading
                ? const Center(child: CircularProgressIndicator())  // Afficher le spinner si en cours de chargement
                : Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final sender = message['Sender'];
                  final senderUsername = sender != null ? sender['username'] ?? 'Inconnu' : 'Inconnu';
                  final createdAt = message['createdAt'] ?? '';  // Check if created_at is null
                  final formattedDate = createdAt.isNotEmpty
                      ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(createdAt).toLocal())
                      : 'Date inconnue';  // Handle null dates
                  final bool isSentByMe = sender != null && sender['id'] == user.id;
                  if (kDebugMode) {
                    print('Message: $message');
                  }

                  return Align(
                    alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isSentByMe ? Colors.green[300] : Colors.blue[300],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(15),
                          topRight: const Radius.circular(15),
                          bottomLeft: isSentByMe ? const Radius.circular(15) : const Radius.circular(0),
                          bottomRight: isSentByMe ? const Radius.circular(0) : const Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            senderUsername,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSentByMe ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            message['message'] ?? 'Message vide',  // Check if message is null
                            style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            formattedDate,
                            style: TextStyle(fontSize: 10, color: isSentByMe ? Colors.white70 : Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Tapez votre message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(child: Text('Utilisateur non authentifié'));
    }
  }
}
