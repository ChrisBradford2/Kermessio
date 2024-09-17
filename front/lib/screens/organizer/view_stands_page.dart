import 'package:flutter/material.dart';

class ViewStandsPage extends StatelessWidget {
  const ViewStandsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cette partie doit afficher tous les stands avec les informations demandées (stock, jetons dépensés, points attribués)
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            // Exemple d'affichage d'un stand
            ListTile(
              title: Text('Stand 1'),
              subtitle: Text('Stock : 10 | Jetons dépensés : 30 | Points attribués : 50'),
            ),
            // Ajoute d'autres stands de manière similaire
          ],
        ),
      ),
    );
  }
}
