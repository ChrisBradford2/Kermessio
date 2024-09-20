import 'package:flutter/material.dart';

class CreateKermessePage extends StatefulWidget {
  const CreateKermessePage({super.key});

  @override
  CreateKermessePageState createState() => CreateKermessePageState();
}

class CreateKermessePageState extends State<CreateKermessePage> {
  final TextEditingController _kermesseNameController = TextEditingController();

  Future<void> _createKermesse() async {
    final kermesseName = _kermesseNameController.text;
    if (kermesseName.isNotEmpty) {
      // Envoyer la requête au backend pour créer une nouvelle kermesse
      // Example:
      // final response = await http.post(...)
      Navigator.pop(context, 'Kermesse créée avec succès');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une nouvelle kermesse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _kermesseNameController,
              decoration: const InputDecoration(labelText: 'Nom de la kermesse'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createKermesse,
              child: const Text('Créer la kermesse'),
            ),
          ],
        ),
      ),
    );
  }
}
