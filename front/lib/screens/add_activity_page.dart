import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

class AddActivityPage extends StatefulWidget {
  final ActivityRepository activityRepository;

  const AddActivityPage({super.key, required this.activityRepository});

  @override
  AddActivityPageState createState() => AddActivityPageState();
}

class AddActivityPageState extends State<AddActivityPage> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _emojiController = TextEditingController();
  final _priceController = TextEditingController();
  final _pointsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une activité"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'activité',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de l\'activité';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type d\'activité',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le type de l\'activité';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emojiController,
                decoration: const InputDecoration(
                  labelText: 'Emoji (facultatif)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix en jetons',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix en jetons';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(
                  labelText: 'Points attribués',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de points';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveActivity();
                    }
                  },
                  child: const Text('Enregistrer l\'activité'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveActivity() async {
    final name = _nameController.text;
    final type = _typeController.text;
    final emoji = _emojiController.text.isNotEmpty ? _emojiController.text : null;
    final price = int.tryParse(_priceController.text);
    final points = int.tryParse(_pointsController.text);

    // Vérifier les données
    if (price == null || points == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer des valeurs valides')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final activity = Activity(
      id: 0,
      name: name,
      type: type,
      emoji: emoji,
      price: price,
      points: points,
      boothHolderId: 0,
    );

    try {
      final createdActivity = await widget.activityRepository.createActivity(activity);

      if (createdActivity != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activité enregistrée avec succès')),
        );
        _formKey.currentState?.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création de l\'activité')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
