import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/child_repository.dart';

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
                : ElevatedButton(
              onPressed: _assignTokens,
              child: const Text("Attribuer"),
            ),
          ],
        ),
      ),
    );
  }

  void _assignTokens() async {
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
      final parentToken = "Bearer YOUR_PARENT_TOKEN"; // Récupère le token du parent ici
      final success = await childRepository.assignTokensToChild(
        childId: widget.child.id.toString(),
        tokens: tokens,
        token: parentToken,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jetons attribués avec succès')),
        );
        Navigator.pop(context); // Retour à la page précédente
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
