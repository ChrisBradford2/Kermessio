import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../blocs/child_bloc.dart';
import '../blocs/child_event.dart';
import '../blocs/child_state.dart';
import 'buy_tokens_page.dart';
import 'child_details_page.dart';
import 'create_child_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("HomePage build");
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Gérer l'état déjà Authenticated lors de la construction
        if (authState is AuthAuthenticated) {
          if (kDebugMode) {
            print("Utilisateur déjà authentifié lors de la construction, token : ${authState.token}");
          }
          if (authState.token.isNotEmpty) {
            final childBloc = context.read<ChildBloc>();
            if (kDebugMode) {
              print("ChildBloc récupéré avec succès : $childBloc");
              print("Déclenchement de LoadChildren avec le token : ${authState.token}");
            }
            childBloc.add(LoadChildren(parentToken: authState.token));
          } else {
            if (kDebugMode) {
              print("Le token est nul ou vide !");
            }
          }
        }

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            // Gérer les changements d'état Authenticated via listener
            if (authState is AuthAuthenticated) {
              if (kDebugMode) {
                print("Utilisateur authentifié via listener, token : ${authState.token}");
              }
              if (authState.token.isNotEmpty) {
                final childBloc = context.read<ChildBloc>();
                if (kDebugMode) {
                  print("ChildBloc récupéré avec succès via listener : $childBloc");
                  print("Déclenchement de LoadChildren avec le token via listener : ${authState.token}");
                }
                childBloc.add(LoadChildren(parentToken: authState.token));
              } else {
                if (kDebugMode) {
                  print("Le token est nul ou vide !");
                }
              }
            } else {
              if (kDebugMode) {
                print("Utilisateur non authentifié");
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Bienvenue à Kermessio"),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                )
              ],
              leading: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    final tokenText = state.user.tokens > 0
                        ? '${state.user.tokens}'
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          tokenText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Bienvenue sur Kermessio !",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
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
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return Text(
                          "${state.user.tokens} jetons",
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return const Text(
                          "0 jeton",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    },
                  ),
                  const Text(
                    "Liste des enfants",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: BlocBuilder<ChildBloc, ChildState>(
                      builder: (context, state) {
                        if (state is ChildInitial) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ChildLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ChildLoaded) {
                          if (state.children.isEmpty) {
                            return const Center(child: Text("Aucun enfant trouvé."));
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
                                        builder: (context) => ChildDetailsPage(child: child),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
                        } else if (state is ChildError) {
                          if (kDebugMode) {
                            print("Erreur dans ChildBloc : ${state.message}");
                          }
                          return Center(child: Text("Erreur: ${state.message}"));
                        } else {
                          if (kDebugMode) {
                            print("État inconnu: $state");
                          }
                          return const Center(child: Text("Erreur de chargement."));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
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
                      _redirectToBuyTokens(context); // Rediriger vers la page d'achat de tokens
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Acheter des tokens"),
                  ),
                  const SizedBox(height: 50.0),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Déconnexion",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _redirectToBuyTokens(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BuyTokensPage(),
      ),
    );
  }
}
