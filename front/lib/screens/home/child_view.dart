import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../repositories/stock_repository.dart';
import '../buy_stock_page.dart';

class ChildView extends StatelessWidget {
  final User user;
  final StockRepository stockRepository;

  const ChildView({
    super.key,
    required this.user,
    required this.stockRepository
  });

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
              "Ton solde de jetons : ${user.tokens} jetons",
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action pour participer à une activité ou autre
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
                      stockRepository: stockRepository,
                      user: user,
                    ),
                  ),
                );
              },
              child: const Text("Acheter un consommable"),
            ),
          ],
        ),
      ),
    );
  }
}
