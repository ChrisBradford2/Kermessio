import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';

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
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;
      final senderId = authState.user.id;
      final url =
          '${AppConfig().baseUrl}/chat/messages?sender_id=$senderId&receiver_id=${widget.boothHolderId}';

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
            _messages = data['messages'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erreur lors de la récupération des messages')),
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

  Future<void> _sendMessage() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;
      final senderId = authState.user.id;
      final messageText = _messageController.text;

      if (messageText.isEmpty) return;

      final url = '${AppConfig().baseUrl}/chat/messages'; // URL à adapter

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'sender_id': senderId,
          'receiver_id': widget.boothHolderId,
          'message': messageText,
        }),
      );

      if (response.statusCode == 200) {
        _messageController.clear();
        _fetchMessages(); // Actualiser la liste des messages après l'envoi
      } else {
        print('Error sending message: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi du message')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non authentifié')),
      );
    }
  }

  String formatDate(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec ${widget.boothHolderUsername}'),
      ),
      body: Column(
        children: <Widget>[
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isSentByMe = message['Sender']['username'] == 'Me'; // Add logic to check if it's the current user
                return Align(
                  alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isSentByMe ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['Sender']['username'] ?? 'Inconnu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSentByMe ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          message['message'] ?? '',
                          style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatDate(message['createdAt']),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSentByMe ? Colors.white70 : Colors.black45,
                          ),
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
  }
}
