import 'package:flutter/material.dart';

class ViewGlobalRevenuePage extends StatelessWidget {
  const ViewGlobalRevenuePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cette partie doit afficher les recettes globales, comme le total des jetons achetés
    return const Scaffold(
      body: Center(
        child: Text(
          'Jetons achetés : 2000',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
