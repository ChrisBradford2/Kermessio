import 'package:flutter/material.dart';

import '../widgets/logout_widget.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const CustomScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kermessio"),
        actions: const [
          LogoutWidget(),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}