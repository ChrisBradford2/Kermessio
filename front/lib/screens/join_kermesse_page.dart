import 'package:flutter/material.dart';

class JoinKermessePage extends StatefulWidget {
  const JoinKermessePage({super.key});

  @override
  JoinKermessePageState createState() => JoinKermessePageState();
}

class JoinKermessePageState extends State<JoinKermessePage> {
  final TextEditingController _codeController = TextEditingController();

  Future<void> _joinKermesse() async {
    final code = _codeController.text;
    if (code.isNotEmpty) {
      // Envoyer la requête au backend pour rejoindre la kermesse via le code
      // Example:
      // final response = await http.post(...)
      Navigator.pop(context, 'Vous avez rejoint la kermesse avec succès');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre une kermesse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code de kermesse'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinKermesse,
              child: const Text('Rejoindre la kermesse'),
            ),
          ],
        ),
      ),
    );
  }
}
