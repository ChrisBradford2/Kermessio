import 'package:flutter/material.dart';
import '../models/user_model.dart';

class BoothHolderView extends StatelessWidget {
  final User user;

  const BoothHolderView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bienvenue à Kermessio - Teneur de stand")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Bienvenue sur Kermessio, Teneur de stand !",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page pour ajouter des activités
              },
              child: const Text("Ajouter une activité"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page pour définir les prix des produits
              },
              child: const Text("Définir les prix des produits"),
            ),
          ],
        ),
      ),
    );
  }
}
