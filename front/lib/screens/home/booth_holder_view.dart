import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../repositories/activity_repository.dart';
import '../../repositories/stock_repository.dart';
import '../add_activity_page.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../add_stock_page.dart';

class BoothHolderView extends StatelessWidget {
  final User user;

  const BoothHolderView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bienvenue à Kermessio - Teneur de stand")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Bienvenue sur Kermessio, Teneur de stand !",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  final activityRepository = ActivityRepository(
                    baseUrl: 'http://10.0.2.2:8080',
                    token: authState.token,
                  );
                  final stockRepository = StockRepository(
                    baseUrl: 'http://10.0.2.2:8080',
                    token: authState.token,
                  );

                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddActivityPage(
                                activityRepository: activityRepository,
                              ),
                            ),
                          );
                        },
                        child: const Text("Ajouter une activité"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddStockPage(
                                stockRepository: stockRepository,
                              ),
                            ),
                          );
                        },
                        child: const Text("Ajouter un consommable"),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text('Vous devez être authentifié pour ajouter une activité ou un consommable'),
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
