import 'package:flutter/material.dart';

class TombolaButton extends StatelessWidget {
  final bool hasBoughtTicket;
  final VoidCallback onBuyTicket;

  const TombolaButton({required this.hasBoughtTicket, required this.onBuyTicket, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: hasBoughtTicket ? null : onBuyTicket,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          hasBoughtTicket ? Colors.grey : Colors.blue,
        ),
      ),
      child: Text(
        hasBoughtTicket
            ? "Ticket de tombola déjà acheté"
            : "Acheter un ticket de tombola (10 jetons)",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
