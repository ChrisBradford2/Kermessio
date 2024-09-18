import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/models/user_model.dart';
import 'package:front/repositories/stock_repository.dart';
import 'package:front/repositories/tombola_repository.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/kermesse_bloc.dart';  // Import du KermesseBloc
import '../../blocs/kermesse_state.dart';
import '../../config/app_config.dart';
import '../../models/purchase_model.dart';
import '../../repositories/activity_repository.dart';
import '../../repositories/participation_repository.dart';
import '../../repositories/purchase_repository.dart';
import '../activities_page.dart';
import '../buy_stock_page.dart';
import '../purchase_code_page.dart';

class ChildView extends StatefulWidget {
  final User user;
  final StockRepository stockRepository;

  const ChildView({
    Key? key,
    required this.user,
    required this.stockRepository,
  }) : super(key: key);

  @override
  _ChildViewState createState() => _ChildViewState();
}

class _ChildViewState extends State<ChildView> {
  List<Purchase> purchases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is AuthAuthenticated) {
      final purchaseRepository = PurchaseRepository(
        baseUrl: AppConfig().baseUrl,
        token: authState.token,
      );

      try {
        final fetchedPurchases = await purchaseRepository.fetchPurchasesByUser(widget.user.id);
        setState(() {
          purchases = fetchedPurchases;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching purchases: $e');
      }
    }
  }

  // Méthode pour acheter un ticket de tombola avec l'ID de la kermesse récupéré via le BLoC
  Future<void> _buyTombolaTicket(int kermesseId) async {
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is AuthAuthenticated) {
      final tombolaRepository = TombolaRepository(
        baseUrl: AppConfig().baseUrl,
        token: authState.token,
      );

      if (widget.user.tokens >= 10) { // Vérification du solde de jetons
        try {
          final response = await tombolaRepository.buyTicket(widget.user.id, widget.user.role, kermesseId);
          if (response['success']) {
            setState(() {
              widget.user.tokens -= 10; // Déduire 10 jetons après l'achat
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ticket de tombola acheté avec succès!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['error'] ?? 'Erreur lors de l\'achat du ticket.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solde insuffisant de jetons.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
              "Ton solde de jetons : ${widget.user.tokens} jetons",
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
                                stockRepository: widget.stockRepository,
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        child: const Text("Acheter un consommable"),
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<KermesseBloc, KermesseState>(
                        builder: (context, kermesseState) {
                          if (kermesseState is KermesseSelected) {
                            return ElevatedButton(
                              onPressed: () {
                                _buyTombolaTicket(kermesseState.kermesseId); // Passer l'ID de la kermesse ici
                              },
                              child: const Text("Acheter un ticket de tombola (10 jetons)"),
                            );
                          } else {
                            return const ElevatedButton(
                              onPressed: null,
                              child: Text("Acheter un ticket de tombola (10 jetons)"),
                            );
                          }
                        },
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
            const SizedBox(height: 20),
            const Text(
              "Tes achats :",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(child: _buildPurchaseList()),
          ],
        ),
      ),
    );
  }

  // Construction de la liste des achats
  Widget _buildPurchaseList() {
    if (purchases.isEmpty) {
      return const Text("Aucun achat effectué");
    }

    return ListView.builder(
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        return ListTile(
          title: Text(purchase.itemName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantité : ${purchase.quantity}, Prix : ${purchase.price} jetons'),
              Chip(
                label: Text(
                  purchase.status == 'approved' ? 'Validé' :
                  purchase.status == 'rejected' ? 'Refusé' :
                  'En attente',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: purchase.status == 'approved' ? Colors.green :
                purchase.status == 'rejected' ? Colors.red :
                Colors.orange,
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PurchaseCodePage(purchase: purchase),
              ),
            );
          },
        );
      },
    );
  }
}
