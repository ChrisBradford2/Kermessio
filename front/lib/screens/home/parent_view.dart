import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/scaffold/custom_scaffold.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/child_bloc.dart';
import '../../blocs/child_event.dart';
import '../../blocs/child_state.dart';
import '../child/create_child_page.dart';
import '../tokens/buy_tokens_page.dart';
import '../child/child_details_page.dart';
import '../../models/user_model.dart';

class ParentView extends StatelessWidget {
  final User user;

  const ParentView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          final childBloc = context.read<ChildBloc>();
          childBloc.add(LoadChildren(parentToken: authState.token));

          return CustomScaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Bienvenue sur Kermessio, ${user.username} !",
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30.0),
                  const Text(
                    "Votre solde de jetons est de :",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    "${authState.user.tokens} jetons",
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  BlocBuilder<ChildBloc, ChildState>(
                    builder: (context, state) {
                      final childLength = state is ChildLoaded
                          ? state.children.length
                          : 0;

                      return Text(
                        "Liste des enfants ($childLength)",
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: BlocBuilder<ChildBloc, ChildState>(
                      builder: (context, state) {
                        if (state is ChildLoading || state is ChildInitial) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is ChildLoaded) {
                          if (state.children.isEmpty) {
                            return const Center(
                                child: Text("Aucun enfant trouvé."));
                          } else {
                            return ListView.builder(
                              itemCount: state.children.length,
                              itemBuilder: (context, index) {
                                final child = state.children[index];
                                return ListTile(
                                  title: Text(child.username),
                                  subtitle: Text("Jetons: ${child.tokens}"),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChildDetailsPage(child: child),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
                        } else if (state is ChildError) {
                          return Center(
                              child: Text("Erreur: ${state.message}"));
                        }
                        return const Center(
                            child: Text("Erreur de chargement."));
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateChildPage()),
                      );
                    },
                    child: const Text("Créer un compte enfant"),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      _redirectToBuyTokens(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Acheter des tokens"),
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _redirectToBuyTokens(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BuyTokensPage()),
    );
  }
}
