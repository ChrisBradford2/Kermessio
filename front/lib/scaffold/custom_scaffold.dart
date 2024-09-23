import 'package:flutter/material.dart';

import '../widgets/logout_widget.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;

  const CustomScaffold({
    super.key,
    required this.body,
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
    );
  }
}