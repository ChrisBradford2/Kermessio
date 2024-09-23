import 'package:flutter/material.dart';
import 'package:front/repositories/participation_repository.dart';

import '../models/activity_model.dart';
import '../models/user_model.dart';
import '../repositories/activity_repository.dart';

class ActivitiesPage extends StatefulWidget {
  final ActivityRepository activityRepository;
  final ParticipationRepository participationRepository;
  final User user;

  const ActivitiesPage({
    super.key,
    required this.activityRepository,
    required this.participationRepository,
    required this.user
  });

  @override
  ActivitiesPageState createState() => ActivitiesPageState();
}

class ActivitiesPageState extends State<ActivitiesPage> {
  List<Activity> availableActivities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableActivities();
  }

  void _fetchAvailableActivities() async {
    try {
      final activities = await widget.activityRepository.fetchAllActivities();
      if (!mounted) return;
      setState(() {
        availableActivities = activities;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de la récupération des activités : $e'),
      ));
    }
  }

  void _participateInActivity(Activity activity) async {
    if (widget.user.tokens >= activity.price) {
      try {
        final success = await widget.participationRepository.participateInActivity(activity.id, widget.user.id);
        if (!mounted) return;
        if (success) {
          setState(() {
            widget.user.tokens -= activity.price;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Vous avez participé à l\'activité ${activity.name} pour ${activity.price} jetons'),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Erreur lors de la participation'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vous n\'avez pas assez de jetons'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participer à une activité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : availableActivities.isEmpty
            ? const Center(child: Text('Aucune activité disponible pour le moment.'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activités disponibles',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: availableActivities.length,
                itemBuilder: (context, index) {
                  final activity = availableActivities[index];
                  return ListTile(
                    title: Text(activity.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prix : ${activity.price} jetons'),
                        Text('Type : ${activity.type}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _participateInActivity(activity);
                      },
                      child: const Text('Participer'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Jetons restants : ${widget.user.tokens}',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
