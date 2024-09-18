import 'package:flutter/material.dart';
import 'package:front/widgets/child/purchase_status_chip_widget.dart';

import '../../models/purchase_model.dart';
import '../../screens/purchase_code_page.dart';

class PurchaseList extends StatelessWidget {
  final List<Purchase> purchases;

  const PurchaseList({required this.purchases, super.key});

  @override
  Widget build(BuildContext context) {
    if (purchases.isEmpty) {
      return const Text("Aucun achat effectué");
    }

    return ListView.builder(
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        return ListTile(
          title: Text(purchase.itemName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantité : ${purchase.quantity}, Prix : ${purchase.price} jetons'),
              PurchaseStatusChip(status: purchase.status),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PurchaseCodePage(purchase: purchase)),
            );
          },
        );
      },
    );
  }
}
