import 'package:flutter/material.dart';

class TombolaManagementPage extends StatelessWidget {
  const TombolaManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cette partie gère les lots de la tombola et permet de faire le tirage
    return const Scaffold(
      body: Center(
        child: Text(
          'Gestion des lots de la tombola',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
