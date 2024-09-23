import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/config/app_config.dart';
import 'package:front/repositories/participation_repository.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../models/activity_model.dart';
import '../models/participation_model.dart';

class ActivityDetailsPage extends StatefulWidget {
  final Activity activity;

  const ActivityDetailsPage({super.key, required this.activity});

  @override
  ActivityDetailsPageState createState() => ActivityDetailsPageState();
}

class ActivityDetailsPageState extends State<ActivityDetailsPage> {
  List<Participation> participations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = BlocProvider.of<AuthBloc>(context).state;
      if (authState is AuthAuthenticated) {
        _fetchParticipants(authState.token);
      }
    });
  }

  Future<void> _fetchParticipants(String token) async {
    try {
      final participationRepository = ParticipationRepository(
        baseUrl: AppConfig().baseUrl,
        token: token,
      );

      final fetchedParticipations = await participationRepository
          .fetchParticipationsByActivity(widget.activity.id);

      setState(() {
        participations = fetchedParticipations;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPointsModal(BuildContext context, int participationId, String token) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Attribuer points gagnants'),
              onTap: () {
                Navigator.pop(context); // Ferme la modale
                _updateParticipationPoints(participationId, true, token);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Attribuer points normaux'),
              onTap: () {
                Navigator.pop(context); // Ferme la modale
                _updateParticipationPoints(participationId, false, token);
              },
            ),
          ],
        );
      },
    );
  }

  void _updateParticipationPoints(int participationId, bool isWinner, String token) async {
    final participationRepository = ParticipationRepository(
      baseUrl: AppConfig().baseUrl,
      token: token,
    );

    try {
      final success = await participationRepository.updateParticipation(participationId, isWinner);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Points attribués avec succès')),
        );
        _fetchParticipants(token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour des points')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.name),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type : ${widget.activity.type}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Prix : ${widget.activity.price} jetons',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Points : ${widget.activity.points}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Participants :',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                    child: _buildParticipantList(context, authState.token),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Vous devez être authentifié pour voir les détails de l\'activité.'));
        },
      ),
    );
  }

  Widget _buildParticipantList(BuildContext context, String token) {
    if (participations.isEmpty) {
      return const Text("Aucun participant trouvé");
    }

    return ListView.builder(
      itemCount: participations.length,
      itemBuilder: (context, index) {
        final participation = participations[index];
        IconData trailingIcon;

        if (participation.isWinner) {
          trailingIcon = Icons.emoji_events;
        } else if (participation.points > 0) {
          trailingIcon = Icons.star;
        } else {
          trailingIcon = Icons.more_vert;
        }

        return ListTile(
          title: Text('Participant ${participation.userId}'),
          subtitle: Text('Points actuels : ${participation.points}'),
          trailing: IconButton(
            icon: Icon(trailingIcon),
            onPressed: () {
              if (trailingIcon == Icons.more_vert) {
                _showPointsModal(context, participation.id, token);
              }
            },
          ),
        );
      },
    );
  }
}
