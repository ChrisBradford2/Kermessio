import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/repositories/participation_repository.dart';

import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';
import '../../models/user_model.dart';
import '../../repositories/activity_repository.dart';
import '../../repositories/stock_repository.dart';
import '../activities_page.dart';
import '../buy_stock_page.dart';

class ChildView extends StatelessWidget {
  final User user;
  final StockRepository stockRepository;

  const ChildView({
    super.key,
    required this.user,
    required this.stockRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Enfant"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenue dans ton espace !",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Ton solde de jetons : ${user.tokens} jetons",
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return Column(
                    children: [
                      ElevatedButton(
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
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BuyStockPage(
                                stockRepository: stockRepository,
                                user: user,
                              ),
                            ),
                          );
                        },
                        child: const Text("Acheter un consommable"),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text("Vous devez être connecté pour accéder aux activités."),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
