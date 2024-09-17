import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/purchase_model.dart';

class PurchaseCodePage extends StatelessWidget {
  final Purchase purchase;

  const PurchaseCodePage({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final qrPainter = QrPainter(
      data: purchase.validationCode,
      version: QrVersions.auto,
      gapless: false,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'achat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Voici ton code à présenter au teneur de stand :',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Utilisation de CustomPaint pour dessiner le QR code
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: qrPainter,
              ),
            ),

            const SizedBox(height: 20),

            // Affichage du code de validation en texte
            Text(
              purchase.validationCode,
              style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Statut de l'achat
            Text(
              'Statut de l\'achat : ${purchase.status}',
              style: const TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Bouton de retour
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
