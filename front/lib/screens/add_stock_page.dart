import 'package:flutter/material.dart';
import '../repositories/stock_repository.dart';
import '../models/stock_model.dart';

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du consommable',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du consommable';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Veuillez entrer une quantité valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
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
              ),
              const SizedBox(height: 30.0),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveStock();
                    }
                  },
                  child: const Text('Enregistrer le consommable'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveStock() async {
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

      final createdStock = await widget.stockRepository.createStock(newStock);

      if (createdStock != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consommable ajouté avec succès')),
        );
        _formKey.currentState?.reset();
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
