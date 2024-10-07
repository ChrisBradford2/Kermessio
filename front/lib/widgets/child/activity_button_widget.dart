import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';
import '../../repositories/activity_repository.dart';
import '../../repositories/participation_repository.dart';
import '../../screens/activities_page.dart';

class ActivityButton extends StatefulWidget {
  final AuthAuthenticated authState;

  const ActivityButton({required this.authState, super.key});

  @override
  ActivityButtonState createState() => ActivityButtonState();
}

class ActivityButtonState extends State<ActivityButton> {
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
                token: widget.authState.token,
              ),
              participationRepository: ParticipationRepository(
                baseUrl: AppConfig().baseUrl,
                token: widget.authState.token,
              ),
              user: widget.authState.user,
            ),
          ),
        ).then((_) {
          if (mounted) {
            context.read<AuthBloc>().add(AuthRefreshRequested());
          }
        });
      },
      child: const Text("Participer à une activité"),
    );
  }
}
