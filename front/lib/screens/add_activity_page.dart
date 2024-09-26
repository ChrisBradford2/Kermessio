import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';
import '../blocs/kermesse_bloc.dart';
import '../blocs/kermesse_state.dart';

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
        child: BlocBuilder<KermesseBloc, KermesseState>(
          builder: (context, kermesseState) {
            if (kermesseState is KermesseSelected) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTextInput(_nameController, 'Nom de l\'activité'),
                    const SizedBox(height: 16.0),
                    _buildTextInput(_typeController, 'Type d\'activité'),
                    const SizedBox(height: 16.0),
                    _buildTextInput(_emojiController, 'Emoji (facultatif)'),
                    const SizedBox(height: 16.0),
                    _buildTextInput(_priceController, 'Prix en jetons', isNumber: true),
                    const SizedBox(height: 16.0),
                    _buildTextInput(_pointsController, 'Points attribués', isNumber: true),
                    const SizedBox(height: 30.0),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveActivity(kermesseState.kermesseId);
                          }
                        },
                        child: const Text('Enregistrer l\'activité'),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Veuillez sélectionner une kermesse avant de continuer.'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (label == 'Emoji (facultatif)') {
          return null;
        }
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        if (isNumber && int.tryParse(value) == null) {
          return 'Veuillez entrer un nombre valide';
        }
        return null;
      },
    );
  }

  void _saveActivity(int kermesseId) async {
    final name = _nameController.text;
    final type = _typeController.text;
    final emoji = _emojiController.text.isNotEmpty ? _emojiController.text : null;
    final price = int.tryParse(_priceController.text);
    final points = int.tryParse(_pointsController.text);

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
      kermesseId: kermesseId,
    );

    try {
      final createdActivity = await widget.activityRepository.createActivity(activity);
      if (!mounted) return;

      if (createdActivity != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activité enregistrée avec succès')),
        );
        Navigator.pop(context, 'Activité enregistrée avec succès');
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
