import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../screens/tombola_status_page.dart';
import '../../blocs/kermesse_bloc.dart';
import '../../blocs/kermesse_state.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';

class TombolaButton extends StatelessWidget {
  final bool hasBoughtTicket;
  final VoidCallback onBuyTicket;

  const TombolaButton({required this.hasBoughtTicket, required this.onBuyTicket, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (hasBoughtTicket) {
          final kermesseState = context.read<KermesseBloc>().state;
          final authState = context.read<AuthBloc>().state;

          if (kermesseState is KermesseSelected && authState is AuthAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TombolaStatusPage(
                  kermesseId: kermesseState.kermesseId,
                  userId: authState.user.id,
                  token: authState.token,
                ),
              ),
            );
          }
        } else {
          onBuyTicket();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: hasBoughtTicket ? Colors.blue : Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        hasBoughtTicket ? "Voir le statut de la tombola" : "Acheter un ticket de tombola (10 jetons)",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
