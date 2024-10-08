import 'package:flutter/material.dart';
import '../../blocs/auth_event.dart';
import '../../repositories/child_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';

class CreateChildPage extends StatefulWidget {
  const CreateChildPage({super.key});

  @override
  CreateChildPageState createState() => CreateChildPageState();
}

class CreateChildPageState extends State<CreateChildPage> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final ChildRepository childRepository = ChildRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte enfant")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nom d\'utilisateur de l\'enfant'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom d\'utilisateur';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom de l\'enfant'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom de famille de l\'enfant'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de famille';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createChildAccount,
                child: const Text('Créer un compte enfant'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createChildAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Retrieve the parent token from the AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // Call the ChildRepository to create the child account
        final success = await childRepository.createChildAccount(
          username: _usernameController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          password: _passwordController.text,
          token: authState.token,  // Parent's token
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (success) {
          // On success, refresh user data to include the new child
          context.read<AuthBloc>().add(AuthRefreshRequested());

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compte enfant créé avec succès')),
          );

          // Rediriger vers la page ParentView
          Navigator.pop(context, true); // On retourne 'true' pour signaler une création réussie
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la création du compte enfant')),
          );
        }
      }
    }
  }
}
