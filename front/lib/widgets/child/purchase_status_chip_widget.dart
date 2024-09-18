import 'package:flutter/material.dart';

class PurchaseStatusChip extends StatelessWidget {
  final String status;

  const PurchaseStatusChip({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    switch (status) {
      case 'approved':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.orange;
    }

    return Chip(
      label: Text(
        status == 'approved' ? 'Validé' : status == 'rejected' ? 'Refusé' : 'En attente',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }
}
