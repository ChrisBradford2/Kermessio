import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/kermesse_bloc.dart';
import '../blocs/kermesse_state.dart';
import '../config/app_config.dart';
import 'chat_details_page.dart';

class SelectUserForChatPage extends StatefulWidget {
  final bool isOrganizer;

  const SelectUserForChatPage({super.key, required this.isOrganizer});

  @override
  SelectUserForChatPageState createState() => SelectUserForChatPageState();
}

class SelectUserForChatPageState extends State<SelectUserForChatPage> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchUsers(int kermesseId) async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;

      final url = widget.isOrganizer
          ? '${AppConfig().baseUrl}/user/organizer/stands'
          : '${AppConfig().baseUrl}/user/$kermesseId/organizers';

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
            _users = widget.isOrganizer ? data['stands'] : data['organizers'];
            _isLoading = false;
          });
        } else {
          if (kDebugMode) {
            print('Error fetching users: ${response.statusCode} - ${response.body}');
          }
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la récupération des utilisateurs')),
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
      appBar: AppBar(
        title: Text(widget.isOrganizer
            ? 'Sélectionner un teneur de stand'
            : 'Sélectionner un organisateur'),
      ),
      body: BlocBuilder<KermesseBloc, KermesseState>(
        builder: (context, kermesseState) {
          if (kermesseState is KermesseSelected) {
            _fetchUsers(kermesseState.kermesseId);

            return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  child: ListTile(
                    title: Text(user['username']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailsPage(
                            boothHolderId: user['id'],
                            boothHolderUsername: user['username'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Aucune kermesse sélectionnée.'));
          }
        },
      ),
    );
  }
}
