import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/kermesse_bloc.dart';
import '../blocs/kermesse_event.dart';

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({super.key});

  void _logout(BuildContext context) {
    context.read<KermesseBloc>().add(DeselectKermesseEvent());
    context.read<AuthBloc>().add(AuthLogoutRequested());
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Déconnexion',
      onPressed: () => _logout(context),
    );
  }
}
