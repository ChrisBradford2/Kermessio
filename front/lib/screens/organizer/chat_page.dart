import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple d'interface de chat
    return const Scaffold(
      body: Center(
        child: Text(
          'Chat avec les teneurs de stand',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
