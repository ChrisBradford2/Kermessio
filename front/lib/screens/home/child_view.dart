import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/repositories/tombola_repository.dart';
import 'package:front/scaffold/custom_scaffold.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/kermesse_bloc.dart';
import '../../blocs/kermesse_state.dart';
import '../../config/app_config.dart';
import '../../models/purchase_model.dart';
import '../../repositories/purchase_repository.dart';
import '../../widgets/child/activity_button_widget.dart';
import '../../widgets/child/buy_stock_button.dart';
import '../../widgets/child/child_view_widget.dart';
import '../../widgets/child/purchase_list.dart';
import '../../widgets/child/tombola_button_widget.dart';

class ChildViewState extends State<ChildView> {
  List<Purchase> purchases = [];
  bool isLoading = true;
  bool hasBoughtTombolaTicket = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkIfTombolaTicketBought();
    await _fetchPurchases();
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
        if (kDebugMode) {
          print('Error fetching purchases: $e');
        }
      }
    }
  }

  Future<void> _checkIfTombolaTicketBought() async {
    final authState = BlocProvider.of<AuthBloc>(context).state;
    final kermesseState = BlocProvider.of<KermesseBloc>(context).state;

    if (authState is AuthAuthenticated && kermesseState is KermesseSelected) {
      final tombolaRepository = TombolaRepository(
        baseUrl: AppConfig().baseUrl,
        token: authState.token,
      );
      final hasTicket = await tombolaRepository.checkIfUserHasTicket(
        userId: widget.user.id,
        kermesseId: kermesseState.kermesseId,
      );
      setState(() {
        hasBoughtTombolaTicket = hasTicket;
      });
    }
  }

  Future<void> _buyTombolaTicket(int kermesseId) async {
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is AuthAuthenticated) {
      final tombolaRepository = TombolaRepository(
        baseUrl: AppConfig().baseUrl,
        token: authState.token,
      );
      if (widget.user.tokens >= 10) {
        try {
          final response = await tombolaRepository.buyTicket(widget.user.id, widget.user.role, kermesseId);
          if (!mounted) return;
          if (response['success']) {
            setState(() {
              hasBoughtTombolaTicket = true;
            });
            BlocProvider.of<AuthBloc>(context).add(AuthRefreshRequested());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket de tombola acheté avec succès!'), backgroundColor: Colors.green),
            );
          } else {
            _showError(response['error'] ?? 'Erreur lors de l\'achat du ticket.');
          }
        } catch (e) {
          _showError('Erreur : $e');
        }
      } else {
        _showError('Solde insuffisant de jetons.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildTokenDisplay(),
            const SizedBox(height: 10),
            _buildPointsDisplay(),
            const SizedBox(height: 20),
            _buildActions(context),
            const SizedBox(height: 20),
            _buildPurchasesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Text(
        "Bienvenue dans ton espace, ${widget.user.username}!",
        style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold
        )
    );
  }

  Widget _buildTokenDisplay() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return Text(
            "Ton solde de jetons : ${authState.user.tokens} jetons",
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          );
        } else {
          return const Text(
            "Ton solde de jetons : - jetons",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return Column(
            children: [
              ActivityButton(authState: authState),
              const SizedBox(height: 20),
              BuyStockButton(
                stockRepository: widget.stockRepository,
                user: widget.user,
                onStockPurchased: _fetchPurchases,
              ),
              const SizedBox(height: 20),
              BlocBuilder<KermesseBloc, KermesseState>(
                builder: (context, kermesseState) {
                  if (kermesseState is KermesseSelected) {
                    return TombolaButton(
                      hasBoughtTicket: hasBoughtTombolaTicket,
                      onBuyTicket: () => _buyTombolaTicket(kermesseState.kermesseId),
                    );
                  } else {
                    return TombolaButton(hasBoughtTicket: true, onBuyTicket: () {});
                  }
                },
              ),
            ],
          );
        } else {
          return const Center(child: Text("Vous devez être connecté pour accéder aux activités."));
        }
      },
    );
  }

  Widget _buildPointsDisplay() {
    return Text(
      "Ton nombre de points : ${widget.user.points} points",
      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }


  Widget _buildPurchasesSection() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Expanded(child: PurchaseList(purchases: purchases));
  }
}
