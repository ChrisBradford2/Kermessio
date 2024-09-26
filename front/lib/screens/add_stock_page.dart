import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/stock_repository.dart';
import '../models/stock_model.dart';
import '../blocs/kermesse_bloc.dart';
import '../blocs/kermesse_state.dart';

class AddStockPage extends StatefulWidget {
  final StockRepository stockRepository;

  const AddStockPage({super.key, required this.stockRepository});

  @override
  AddStockPageState createState() => AddStockPageState();
}

class AddStockPageState extends State<AddStockPage> {
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un consommable"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<KermesseBloc, KermesseState>(
          builder: (context, kermesseState) {
            // Vérifier si une kermesse est sélectionnée
            if (kermesseState is KermesseSelected) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTextInputField(_itemNameController, 'Nom du consommable'),
                    const SizedBox(height: 16.0),
                    _buildTextInputField(_quantityController, 'Quantité', isNumeric: true),
                    const SizedBox(height: 16.0),
                    _buildTextInputField(_priceController, 'Prix', isNumeric: true),
                    const SizedBox(height: 16.0),
                    _buildDropdown(),
                    const SizedBox(height: 30.0),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveStock(kermesseState.kermesseId);
                          }
                        },
                        child: const Text('Enregistrer le consommable'),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Veuillez sélectionner une kermesse avant de continuer.'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextInputField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        if (isNumeric && int.tryParse(value) == null) {
          return 'Veuillez entrer un nombre valide';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Type (Boisson ou Nourriture)',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Boisson',
          child: Text('Boisson'),
        ),
        DropdownMenuItem(
          value: 'Nourriture',
          child: Text('Nourriture'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedType = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner un type';
        }
        return null;
      },
    );
  }

  void _saveStock(int kermesseId) async {
    final itemName = _itemNameController.text;
    final quantity = int.tryParse(_quantityController.text);
    final price = int.tryParse(_priceController.text);
    final type = _selectedType;

    if (quantity == null || price == null || type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer des valeurs valides')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newStock = Stock(
        id: 0,
        itemName: itemName,
        quantity: quantity,
        price: price,
        type: type,
        boothHolderId: 0,
      );

      final createdStock = await widget.stockRepository.createStock(newStock, kermesseId);
      if (!mounted) return;

      if (createdStock != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consommable ajouté avec succès')));

        Navigator.pop(context, 'Consommable ajouté avec succès');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
