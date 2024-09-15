import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import 'parent_view.dart';
import 'booth_holder_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          if (authState.user.role == 'parent') {
            return ParentView(user: authState.user);
          } else if (authState.user.role == 'booth_holder') {
            return BoothHolderView(user: authState.user);
          }
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
