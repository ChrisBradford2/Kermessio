import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../repositories/stock_repository.dart';
import '../../screens/buy_stock_page.dart';

class BuyStockButton extends StatelessWidget {
  final StockRepository stockRepository;
  final User user;

  const BuyStockButton({required this.stockRepository, required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyStockPage(stockRepository: stockRepository, user: user),
          ),
        );
      },
      child: const Text("Acheter un consommable"),
    );
  }
}
