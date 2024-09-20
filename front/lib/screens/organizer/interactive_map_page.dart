import 'package:flutter/material.dart';

class InteractiveMapPage extends StatelessWidget {
  const InteractiveMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cette partie doit afficher un plan interactif des stands
    return const Scaffold(
      body: Center(
        child: Text(
          'Plan interactif de la kermesse',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
