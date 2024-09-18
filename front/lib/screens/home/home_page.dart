import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/kermesse_bloc.dart';
import '../../blocs/kermesse_state.dart';
import '../../config/app_config.dart';
import '../../repositories/stock_repository.dart';
import '../select_kermesse_page.dart';
import 'child_view.dart';
import 'parent_view.dart';
import 'booth_holder_view.dart';
import 'organizer_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          final stockRepository = StockRepository(
            baseUrl: AppConfig().baseUrl,
            token: authState.token,
          );

          // Ajout d'une vérification constante pour la sélection de kermesse
          return BlocListener<KermesseBloc, KermesseState>(
            listener: (context, state) {
              if (state is KermesseInitial) {
                print("Kermesse non sélectionnée, redirection vers SelectKermessePage");
              } else if (state is KermesseSelected) {
                print("Kermesse sélectionnée: ${state.kermesseId}");
              }
            },
            child: BlocBuilder<KermesseBloc, KermesseState>(
              builder: (context, kermesseState) {
                if (authState.user.role == 'organizer') {
                  if (kIsWeb) {
                    return OrganizerView(token: authState.token);
                  } else {
                    return const Scaffold(
                      body: Center(
                        child: Text(
                          'Cette vue est uniquement disponible sur un navigateur.',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }
                } else {
                  // Si l'utilisateur n'a pas encore sélectionné de kermesse
                  if (kermesseState is KermesseInitial) {
                    return const SelectKermessePage();
                  }

                  if (authState.user.role == 'parent') {
                    return ParentView(user: authState.user);
                  } else if (authState.user.role == 'booth_holder') {
                    return BoothHolderView(user: authState.user);
                  } else if (authState.user.role == 'child') {
                    return ChildView(
                      user: authState.user,
                      stockRepository: stockRepository,
                    );
                  }
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
