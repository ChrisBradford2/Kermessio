import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/scaffold/custom_scaffold.dart';
import 'package:front/screens/booth_holder_chat_list_page.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';
import '../../models/activity_model.dart';
import '../../models/stock_model.dart';
import '../../models/user_model.dart';
import '../../repositories/activity_repository.dart';
import '../../repositories/stock_repository.dart';
import '../activity_details_page.dart';
import '../add_activity_page.dart';
import '../add_stock_page.dart';
import '../scan_or_enter_code_page.dart';
import '../update_stock_page.dart';

class BoothHolderView extends StatefulWidget {
  final User user;

  const BoothHolderView({super.key, required this.user});

  @override
  BoothHolderViewState createState() => BoothHolderViewState();
}

class BoothHolderViewState extends State<BoothHolderView> {
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
        baseUrl: AppConfig().baseUrl,
        token: authState.token,
      );
      final stockRepository = StockRepository(
        baseUrl: AppConfig().baseUrl,
        token: authState.token,
      );

      try {
        final fetchedActivities = await activityRepository.fetchActivities();
        final fetchedStocks = await stockRepository.fetchStocks();
        setState(() {
          activities = fetchedActivities;
          stocks = fetchedStocks;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
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
                    _buildActionGrid(),
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

  Widget _buildActionGrid() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;

      return GridView.count(
        crossAxisCount: 2, // Nombre de carrés par ligne
        shrinkWrap: true,
        mainAxisSpacing: 5, // Espace entre les carrés verticalement
        crossAxisSpacing: 5, // Espace entre les carrés horizontalement
        childAspectRatio: 2, // Ajuste le ratio largeur/hauteur des carrés
        children: [
          _buildActionTile(
            icon: Icons.add_circle_outline,
            label: 'Ajouter une activité',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddActivityPage(
                    activityRepository: ActivityRepository(
                      baseUrl: AppConfig().baseUrl,
                      token: token,
                    ),
                  ),
                ),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.fastfood,
            label: 'Ajouter un consommable',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddStockPage(
                    stockRepository: StockRepository(
                      baseUrl: AppConfig().baseUrl,
                      token: token,
                    ),
                  ),
                ),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.qr_code_scanner,
            label: 'Scanner un code',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanAndValidateOrderPage(),
                ),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.message,
            label: 'Chatter avec l\'organisateur',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BoothHolderChatListPage(),
                ),
              );
            },
          ),
        ],
      );
    } else {
      return const Center(
        child: Text('Vous devez être authentifié pour accéder à ces actions.'),
      );
    }
  }

  Widget _buildActionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30), // Taille de l'icône réduite
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12), // Taille du texte réduite
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailsPage(activity: activity),
                      ),
                    );
                  },
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
                  onTap: () {
                    Map<String, dynamic> stockMap = {
                      'id': stock.id,
                      'item_name': stock.itemName,
                      'quantity': stock.quantity,
                      'price': stock.price,
                    };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateStockPage(stock: stockMap),
                      ),
                    ).then((result) {
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                        _fetchData();
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
