import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../config/app_config.dart';

class PointsRankingPage extends StatefulWidget {
  const PointsRankingPage({super.key});

  @override
  PointsRankingPageState createState() => PointsRankingPageState();
}

class PointsRankingPageState extends State<PointsRankingPage> {
  List<dynamic> _ranking = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final token = authState.token;
      final url = '${AppConfig().baseUrl}/user/organizer/ranking';

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _ranking = data['ranking'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la récupération du classement')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non authentifié')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _ranking.length,
        itemBuilder: (context, index) {
          final user = _ranking[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text((index + 1).toString()), // Position du participant
            ),
            title: Text(user['username'] ?? 'Inconnu'),
            subtitle: Text('Points : ${user['points']}'),
          );
        },
      ),
    );
  }
}
