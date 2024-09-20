import 'package:flutter/material.dart';

class PointsRankingPage extends StatelessWidget {
  const PointsRankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cette partie doit afficher le classement des points des participants
    return const Scaffold(
      body: Center(
        child: Text(
          'Classement des participants',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
