import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../repositories/stock_repository.dart';
import '../../screens/buy_stock_page.dart';

class BuyStockButton extends StatelessWidget {
  final StockRepository stockRepository;
  final User user;
  final VoidCallback onStockPurchased;

  const BuyStockButton({
    required this.stockRepository,
    required this.user,
    required this.onStockPurchased,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyStockPage(stockRepository: stockRepository, user: user),
          ),
        ).then((result) {
          if (result != null && result == 'Achat réussi') {
            onStockPurchased();
          }
        });
      },
      child: const Text("Acheter un consommable"),
    );
  }
}
