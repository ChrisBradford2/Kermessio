import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
import 'home/parent_view.dart';

class SelectKermessePage extends StatefulWidget {
  const SelectKermessePage({super.key});

  @override
  SelectKermessePageState createState() => SelectKermessePageState();
}

class SelectKermessePageState extends State<SelectKermessePage> {
  List<Kermesse> kermesses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKermesses();
  }

  Future<void> _fetchKermesses() async {
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is AuthAuthenticated) {
      try {
        final kermesseRepository = KermesseRepository(
          baseUrl: AppConfig().baseUrl,
          token: authState.token,
        );
        final fetchedKermesses = await kermesseRepository.getKermesses();
        if (!mounted) return;
        setState(() {
          kermesses = fetchedKermesses;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la récupération des kermesses')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sélectionner une Kermesse",
          style: GoogleFonts.caveat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildKermesseList(),
      backgroundColor: Colors.yellow[100], // Fun background color
    );
  }

  Widget _buildKermesseList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView.builder(
        itemCount: kermesses.length,
        itemBuilder: (context, index) {
          final kermesse = kermesses[index];
          return GestureDetector(
            onTap: () {
              _onKermesseSelected(kermesse);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.lightBlueAccent.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.celebration_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      kermesse.name,
                      style: GoogleFonts.caveat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onKermesseSelected(Kermesse kermesse) {
    BlocProvider.of<KermesseBloc>(context)
        .add(SelectKermesseEvent(kermesseId: kermesse.id));

    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is AuthAuthenticated) {
      final stockRepository = StockRepository(
        baseUrl: AppConfig().baseUrl,
        token: authState.token,
      );

      _navigateToRoleBasedView(authState.user, stockRepository);
    }
  }

  void _navigateToRoleBasedView(User user, StockRepository stockRepository) {
    if (user.role == 'parent') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ParentView(user: user),
        ),
      );
    } else if (user.role == 'booth_holder') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BoothHolderView(user: user),
        ),
      );
    } else if (user.role == 'child') {
      Navigator.pushReplacement(
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
