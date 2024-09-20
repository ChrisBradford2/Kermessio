import 'package:flutter/material.dart';
import 'package:front/screens/organizer/points_ranking_page.dart';
import 'package:front/screens/organizer/tombola_management_page.dart';
import 'package:front/screens/organizer/view_global_revenue_page.dart';
import 'package:front/screens/organizer/view_stands_page.dart';

import '../../models/kermesse_model.dart';
import 'chat_page.dart';
import 'interactive_map_page.dart';

class KermesseDetailsPage extends StatefulWidget {
  final Kermesse kermesse;

  const KermesseDetailsPage({super.key, required this.kermesse});

  @override
  KermesseDetailsPageState createState() => KermesseDetailsPageState();
}

class KermesseDetailsPageState extends State<KermesseDetailsPage> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions {
    return [
      const ViewStandsPage(),
      ViewGlobalRevenuePage(kermesseId: widget.kermesse.id),
      const ChatPage(),
      TombolaManagementPage(kermesseId: widget.kermesse.id),
      const PointsRankingPage(),
      const InteractiveMapPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Kermesse : ${widget.kermesse.name}'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Stands',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Recettes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Tombola',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Classement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Plan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
