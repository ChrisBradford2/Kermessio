import 'package:flutter/material.dart';
import 'package:front/config/app_config.dart';
import '../../models/kermesse_model.dart';
import '../../repositories/kermesse_repository.dart';
import '../create_kermesse_page.dart';
import '../join_kermesse_page.dart';
import '../organizer/kermesse_details_page.dart';

class OrganizerView extends StatefulWidget {
  final String token;

  const OrganizerView({super.key, required this.token});

  @override
  _OrganizerViewState createState() => _OrganizerViewState();
}

class _OrganizerViewState extends State<OrganizerView> {
  late KermesseRepository _kermesseRepository;
  List<Kermesse> _kermesses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _kermesseRepository = KermesseRepository(
        baseUrl: AppConfig().baseUrl,
        token: widget.token
    );
    _fetchKermesses();
  }

  Future<void> _fetchKermesses() async {
    try {
      final kermesses = await _kermesseRepository.getKermesses();
      setState(() {
        _kermesses = kermesses;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des kermesses: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des kermesses: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vue Organisateur'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Bienvenue dans la vue organisateur',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_kermesses.isEmpty) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateKermessePage(),
                      ),
                    );
                  },
                  child: const Text('Créer une nouvelle kermesse'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JoinKermessePage(),
                      ),
                    );
                  },
                  child: const Text('Rejoindre une kermesse existante'),
                ),
              ] else ...[
                const Text(
                  'Vos Kermesses :',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true, // Pour que la ListView ne prenne pas tout l'espace
                  itemCount: _kermesses.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(_kermesses[index].name),
                        subtitle: Text('ID : ${_kermesses[index].id}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KermesseDetailsPage(kermesse: _kermesses[index]),
                              ),
                            );
                          },
                          child: const Text('Voir Détails'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
