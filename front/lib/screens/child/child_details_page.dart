import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';
import '../../models/user_model.dart';
import '../../repositories/child_repository.dart';

class ChildDetailsPage extends StatefulWidget {
  final User child;

  const ChildDetailsPage({super.key, required this.child});

  @override
  ChildDetailsPageState createState() => ChildDetailsPageState();
}

class ChildDetailsPageState extends State<ChildDetailsPage> {
  final _tokensController = TextEditingController();
  bool _isLoading = false;
  final ChildRepository childRepository = ChildRepository();
  List<dynamic> _interactions = [];
  bool _isFetchingInteractions = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchChildInteractions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de ${widget.child.username}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Attribuer des jetons à ${widget.child.username}",
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _tokensController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nombre de jetons'),
            ),
            const SizedBox(height: 20.0),
            _isLoading
                ? const CircularProgressIndicator()
                : BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return ElevatedButton(
                    onPressed: () => _assignTokens(state.token),
                    child: const Text("Attribuer"),
                  );
                } else if (state is AuthUnauthenticated) {
                  return const Text('Vous devez être connecté pour attribuer des jetons');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 30),
            _buildInteractionSection(),
          ],
        ),
      ),
    );
  }

  void _assignTokens(String token) async {
    setState(() {
      _isLoading = true;
    });

    final tokens = int.tryParse(_tokensController.text);

    if (tokens == null || tokens <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nombre valide de jetons')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final success = await childRepository.assignTokensToChild(
        childId: widget.child.id.toString(),
        tokens: tokens,
        token: token,
      );

      if (success) {
        context.read<AuthBloc>().add(AuthRefreshRequested());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jetons attribués avec succès')),
        );
        if (Navigator.canPop(context) && mounted) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'attribution des jetons')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch interactions (stocks and activities)
  Future<void> _fetchChildInteractions() async {
    setState(() {
      _isFetchingInteractions = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final url = '${AppConfig().baseUrl}/user/child/${widget.child.id}/interactions';
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${authState.token}',
          },
        );

        print('Response code: ${response.statusCode}');
        print('Response: ${response.body}');
        if (response.statusCode == 200) {
          setState(() {
            _interactions = json.decode(response.body)['interactions'];
            _isFetchingInteractions = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Erreur lors de la récupération des interactions';
            _isFetchingInteractions = false;
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Une erreur s\'est produite : $error';
          _isFetchingInteractions = false;
        });
      }
    }
  }

  // Build interaction section
  Widget _buildInteractionSection() {
    if (_isFetchingInteractions) {
      return const CircularProgressIndicator();
    }

    if (_errorMessage.isNotEmpty) {
      return Text(_errorMessage, style: const TextStyle(color: Colors.red));
    }

    return _interactions.isNotEmpty
        ? Expanded(
      child: ListView.builder(
        itemCount: _interactions.length,
        itemBuilder: (context, index) {
          final interaction = _interactions[index];
          final activity = interaction['activity_id'];
          final stock = interaction['stock'];
          final createdAt = interaction['createdAt'];
          final formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(createdAt).toLocal());
          final boothHolder = interaction['stock'] != null ? interaction['stock']['user'] : null;
          return ListTile(
            title: activity != null
                ? Text('Activité : ${activity['name']}')
                : Text('${stock['type']} : ${stock['item_name']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Quantité: ${interaction['tokens']}'),
                Text('Date: $formattedDate'),
                Row(
                  children: <Widget>[
                    const Text('Chez '),
                    Text(
                      boothHolder != null
                          ? boothHolder['username']
                          : 'un utilisateur inconnu',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    )
        : const Text('Aucune interaction trouvée pour cet enfant.');
  }
}
