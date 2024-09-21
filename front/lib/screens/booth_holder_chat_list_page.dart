import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/screens/select_user_for_chat_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';
import 'chat_details_page.dart'; // Page des détails du chat

class BoothHolderChatListPage extends StatefulWidget {
  const BoothHolderChatListPage({super.key});

  @override
  BoothHolderChatListPageState createState() => BoothHolderChatListPageState();
}

class BoothHolderChatListPageState extends State<BoothHolderChatListPage> {
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
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la récupération des conversations')),
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
      appBar: AppBar(
        title: const Text('Conversations avec les organisateurs'),
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
          print(conversation);
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
          // Démarrer une nouvelle conversation avec un organisateur
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectUserForChatPage(isOrganizer: false),
            ),
          );
        },
        tooltip: 'Démarrer une nouvelle conversation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
