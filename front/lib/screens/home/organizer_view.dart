import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front/config/app_config.dart';
import 'package:front/scaffold/custom_scaffold.dart';
import '../../models/kermesse_model.dart';
import '../../repositories/kermesse_repository.dart';
import '../create_kermesse_page.dart';
import '../join_kermesse_page.dart';
import '../organizer/kermesse_details_page.dart';

class OrganizerView extends StatefulWidget {
  final String token;

  const OrganizerView({super.key, required this.token});

  @override
  OrganizerViewState createState() => OrganizerViewState();
}

class OrganizerViewState extends State<OrganizerView> {
  late KermesseRepository _kermesseRepository;
  List<Kermesse> _kermesses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _kermesseRepository = KermesseRepository(
      baseUrl: AppConfig().baseUrl,
      token: widget.token,
    );
    _fetchKermesses();
  }

  Future<void> _fetchKermesses() async {
    try {
      final kermesses = await _kermesseRepository.getKermesses();
      if (!mounted) return;
      setState(() {
        _kermesses = kermesses;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des kermesses: $e');
      }
      setState(() => _isLoading = false);
      _showSnackBar('Erreur lors du chargement des kermesses: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showKermesseOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Créer une nouvelle kermesse'),
              onTap: () async {
                Navigator.pop(context); // Ferme le modal
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateKermessePage(kermesseRepository: _kermesseRepository),
                  ),
                );
                if (result != null && result == 'Kermesse créée avec succès') {
                  _fetchKermesses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kermesse créée avec succès')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Rejoindre une kermesse existante'),
              onTap: () {
                Navigator.pop(context); // Ferme le modal
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinKermessePage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildKermesseList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _kermesses.length,
      itemBuilder: (context, index) {
        final kermesse = _kermesses[index];
        return Card(
          child: ListTile(
            title: Text(kermesse.name),
            subtitle: Text('ID : ${kermesse.id}'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KermesseDetailsPage(kermesse: kermesse),
                  ),
                );
              },
              child: const Text('Voir Détails'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKermesseButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateKermessePage(kermesseRepository: _kermesseRepository),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
            _kermesses.isEmpty ? _buildKermesseButtons() : _buildKermesseList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showKermesseOptions,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
