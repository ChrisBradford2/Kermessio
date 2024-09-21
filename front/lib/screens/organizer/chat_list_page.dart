import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/config/app_config.dart';
import 'package:front/screens/select_user_for_chat_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../chat_details_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  ChatListPageState createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;
      final url = '${AppConfig().baseUrl}/chat/conversations';

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
            _conversations = data['conversations'] != null ? List.from(data['conversations']) : [];
            _isLoading = false;
          });
        } else {
          if (kDebugMode) {
            print('Erreur: ${response.statusCode} - ${response.body}');
          }
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la récupération des conversations')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur: $e');
        }
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
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? const Center(
        child: Text(
          'Aucune conversation disponible.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          if (kDebugMode) {
            print(conversation);
          }
          return Card(
            child: ListTile(
              title: Text(conversation['username'] ?? 'Inconnu'),
              subtitle: Text(conversation['last_message'] ?? 'Pas de message'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailsPage(
                      boothHolderId: conversation['user_id'],
                      boothHolderUsername: conversation['username'] ?? 'Inconnu',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers la page de sélection des booth_holders
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectUserForChatPage(isOrganizer: true)
            ),
          );
        },
        tooltip: 'Démarrer une nouvelle conversation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
