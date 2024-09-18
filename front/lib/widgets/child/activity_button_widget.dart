import 'package:flutter/material.dart';

import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';
import '../../repositories/activity_repository.dart';
import '../../repositories/participation_repository.dart';
import '../../screens/activities_page.dart';

class ActivityButton extends StatelessWidget {
  final AuthAuthenticated authState;

  const ActivityButton({required this.authState, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivitiesPage(
              activityRepository: ActivityRepository(
                baseUrl: AppConfig().baseUrl,
                token: authState.token,
              ),
              participationRepository: ParticipationRepository(
                baseUrl: AppConfig().baseUrl,
                token: authState.token,
              ),
              user: authState.user,
            ),
          ),
        );
      },
      child: const Text("Participer à une activité"),
    );
  }
}
