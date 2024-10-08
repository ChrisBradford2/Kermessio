import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/config/app_config.dart';
import 'package:front/scaffold/custom_scaffold.dart';
import '../../blocs/kermesse_bloc.dart';
import '../../blocs/kermesse_event.dart';
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
        token: widget.token
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
                if (mounted) Navigator.pop(context);

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateKermessePage(kermesseRepository: _kermesseRepository),
                  ),
                );

                if (result != null && result == 'Kermesse créée avec succès') {
                  if (mounted) {
                    await _fetchKermesses();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kermesse créée avec succès')),
                    );
                  }
                }

              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Rejoindre une kermesse existante'),
              onTap: () {
                if (mounted) Navigator.pop(context);

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

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kermesses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateKermessePage(kermesseRepository: _kermesseRepository),
                  ),
                ).then((result) {
                  if (result != null && result == 'Kermesse créée avec succès') {
                    _fetchKermesses(); // Rafraîchir la liste après la création
                  }
                });
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
        ),
      )
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Vos Kermesses :',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _kermesses.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_kermesses[index].name),
                      subtitle: Text('ID : ${_kermesses[index].id}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.read<KermesseBloc>().add(SelectKermesseEvent(kermesseId: _kermesses[index].id));

                          // Naviguer vers la page des détails de la kermesse
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
          ),
        ),
      ),
      floatingActionButton: _kermesses.isNotEmpty
          ? FloatingActionButton(
        onPressed: _showKermesseOptions,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
