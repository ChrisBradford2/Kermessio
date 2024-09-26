import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../models/user_model.dart';
import '../repositories/stock_repository.dart';

class BuyStockPage extends StatefulWidget {
  final StockRepository stockRepository;
  final User user;

  const BuyStockPage({super.key, required this.stockRepository, required this.user});

  @override
  BuyStockPageState createState() => BuyStockPageState();
}

class BuyStockPageState extends State<BuyStockPage> {
  List<Stock> availableStocks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableStocks();
  }

  // Récupérer les stocks disponibles
  void _fetchAvailableStocks() async {
    try {
      final stocks = await widget.stockRepository.fetchAllStocks();
      if (!mounted) return;
      setState(() {
        availableStocks = stocks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de la récupération des consommables : $e'),
      ));
    }
  }

  // Effectuer l'achat d'un stock via l'API
  void _buyStock(Stock stock) async {
    try {
      final success = await widget.stockRepository.buyStock(stock.id, stock.boothHolderId);
      if (!mounted) return;
      if (success) {
        setState(() {
          widget.user.tokens -= stock.price;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vous avez acheté ${stock.itemName} pour ${stock.price} jetons'),
        ));
        Navigator.pop(context, 'Achat réussi');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors de l\'achat'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acheter un consommable'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : availableStocks.isEmpty
            ? const Center(child: Text('Aucun consommable disponible pour le moment.'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consommables disponibles',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: availableStocks.length,
                itemBuilder: (context, index) {
                  final stock = availableStocks[index];
                  return ListTile(
                    title: Text(stock.itemName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prix : ${stock.price} jetons - Quantité : ${stock.quantity}'),
                        Text('Stand : ${stock.boothHolderUsername ?? 'Inconnu'}',
                            style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _buyStock(stock);
                      },
                      child: const Text('Acheter'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Jetons restants : ${widget.user.tokens}',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
