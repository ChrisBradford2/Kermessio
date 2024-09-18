import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/kermesse_bloc.dart';
import '../blocs/kermesse_event.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../config/app_config.dart';
import '../models/kermesse_model.dart';
import '../models/user_model.dart';
import '../repositories/kermesse_repository.dart';
import '../repositories/stock_repository.dart';
import '../widgets/child/child_view_widget.dart';
import 'home/booth_holder_view.dart';
import 'home/organizer_view.dart';
import 'home/parent_view.dart';

class SelectKermessePage extends StatefulWidget {
  const SelectKermessePage({super.key});

  @override
  _SelectKermessePageState createState() => _SelectKermessePageState();
}

class _SelectKermessePageState extends State<SelectKermessePage> {
  List<Kermesse> kermesses = [];
  bool isLoading = true;

  @override
  void initState() {
    print("InitState");
    super.initState();
    _fetchKermesses();
  }

  Future<void> _fetchKermesses() async {
    final authState = BlocProvider.of<AuthBloc>(context).state;

    print("AuthState: $authState");
    if (authState is AuthAuthenticated) {
      try {
        final kermesseRepository = KermesseRepository(
          baseUrl: AppConfig().baseUrl,
          token: authState.token,
        );
        final fetchedKermesses = await kermesseRepository.getKermesses();
        if (kDebugMode) {
          print('Kermesses récupérées: $fetchedKermesses');
        }
        setState(() {
          kermesses = fetchedKermesses;
          isLoading = false;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de la récupération des kermesses: $e');
        }
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la récupération des kermesses')),
        );
      }
    } else {
      if (kDebugMode) {
        print('Utilisateur non authentifié');
      }
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non authentifié')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sélectionner une kermesse")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: kermesses.length,
        itemBuilder: (context, index) {
          final kermesse = kermesses[index];
          return ListTile(
            title: Text(kermesse.name),
            onTap: () {
              // Passer l'ID de la kermesse au BLoC
              BlocProvider.of<KermesseBloc>(context)
                  .add(SelectKermesseEvent(kermesseId: kermesse.id));

              final authState = BlocProvider.of<AuthBloc>(context).state;
              if (authState is AuthAuthenticated) {
                // Créer un StockRepository
                final stockRepository = StockRepository(
                  baseUrl: AppConfig().baseUrl,
                  token: authState.token,
                );

                // Rediriger vers la vue appropriée selon le rôle de l'utilisateur
                _navigateToRoleBasedView(authState.user, stockRepository);
              }
            },
          );
        },
      ),
    );
  }

  void _navigateToRoleBasedView(User user, StockRepository stockRepository) {
    if (user.role == 'parent') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParentView(user: user),
        ),
      );
    } else if (user.role == 'booth_holder') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BoothHolderView(user: user),
        ),
      );
    } else if (user.role == 'child') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChildView(
            user: user,
            stockRepository: stockRepository,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rôle utilisateur non reconnu.'),
        ),
      );
    }
  }
}
