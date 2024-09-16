import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/activity_model.dart';
import '../../models/stock_model.dart';
import '../../models/user_model.dart';
import '../../repositories/activity_repository.dart';
import '../../repositories/stock_repository.dart';
import '../add_activity_page.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../add_stock_page.dart';

class BoothHolderView extends StatefulWidget {
  final User user;

  const BoothHolderView({super.key, required this.user});

  @override
  _BoothHolderViewState createState() => _BoothHolderViewState();
}

class _BoothHolderViewState extends State<BoothHolderView> {
  List<Activity> activities = [];
  List<Stock> stocks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final activityRepository = ActivityRepository(
        baseUrl: 'http://10.0.2.2:8080',
        token: authState.token,
      );
      final stockRepository = StockRepository(
        baseUrl: 'http://10.0.2.2:8080',
        token: authState.token,
      );

      try {
        print('Fetching data');
        print('Fetching activities');
        final fetchedActivities = await activityRepository.fetchActivities();
        print('Fetching stocks');
        final fetchedStocks = await stockRepository.fetchStocks();
        setState(() {
          activities = fetchedActivities;
          stocks = fetchedStocks;
          isLoading = false;
        });
        print('Data fetched');
        print('Activities: $activities');
        print('Stocks: $stocks');
      } catch (e) {
        print('Error: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
            if (isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: Column(
                  children: [
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
                    const SizedBox(height: 20),
                    _buildActivityList(),
                    const SizedBox(height: 20),
                    _buildStockList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    if (activities.isEmpty) {
      return const Text("Aucune activité trouvée");
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vos Activités",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  title: Text(activity.name),
                  subtitle: Text('Prix : ${activity.price} jetons'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList() {
    if (stocks.isEmpty) {
      return const Text("Aucun consommable trouvé");
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vos Consommables",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                final stock = stocks[index];
                return ListTile(
                  title: Text(stock.itemName),
                  subtitle: Text('Prix : ${stock.price} jetons - Quantité : ${stock.quantity}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
