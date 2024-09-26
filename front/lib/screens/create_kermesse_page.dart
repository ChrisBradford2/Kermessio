import 'package:flutter/material.dart';
import '../repositories/kermesse_repository.dart';

class CreateKermessePage extends StatefulWidget {
  final KermesseRepository kermesseRepository;

  const CreateKermessePage({super.key, required this.kermesseRepository});

  @override
  CreateKermessePageState createState() => CreateKermessePageState();
}

class CreateKermessePageState extends State<CreateKermessePage> {
  final TextEditingController _kermesseNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createKermesse() async {
    final kermesseName = _kermesseNameController.text;
    if (kermesseName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom de la kermesse est obligatoire')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.kermesseRepository.createKermesse(kermesseName);
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.pop(context, 'Kermesse créée avec succès');
      } else {
        throw Exception('Erreur lors de la création de la kermesse');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _createKermesse,
              child: const Text('Créer la kermesse'),
            ),
          ],
        ),
      ),
    );
  }
}
