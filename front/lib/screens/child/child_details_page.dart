import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';
import '../../models/user_model.dart';
import '../../repositories/child_repository.dart';
class ChildDetailsPage extends StatefulWidget {
  final User child;

  const ChildDetailsPage({super.key, required this.child});

  @override
  ChildDetailsPageState createState() => ChildDetailsPageState();
}

class ChildDetailsPageState extends State<ChildDetailsPage> {
  final _tokensController = TextEditingController();
  bool _isLoading = false;
  final ChildRepository childRepository = ChildRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attribuer des tokens à ${widget.child.username}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Attribuer des jetons à ${widget.child.username}",
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _tokensController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nombre de jetons'),
            ),
            const SizedBox(height: 20.0),
            _isLoading
                ? const CircularProgressIndicator()
                : BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return ElevatedButton(
                    onPressed: () => _assignTokens(state.token),
                    child: const Text("Attribuer"),
                  );
                } else if (state is AuthUnauthenticated) {
                  return const Text('Vous devez être connecté pour attribuer des tokens');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _assignTokens(String token) async {
    setState(() {
      _isLoading = true;
    });

    final tokens = int.tryParse(_tokensController.text);

    if (tokens == null || tokens <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nombre valide de jetons')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final success = await childRepository.assignTokensToChild(
        childId: widget.child.id.toString(),
        tokens: tokens,
        token: token,
      );

      if (success) {
        context.read<AuthBloc>().add(AuthRefreshRequested());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jetons attribués avec succès')),
        );
        if (Navigator.canPop(context) && mounted) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'attribution des jetons')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
