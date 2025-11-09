import 'package:flutter/material.dart';
import 'package:gestionstage/ajoutRaport.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(), // Page d'accueil avec les boutons
    );
  }
}

// Page d'accueil avec les boutons
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de stage'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue dans l’application de gestion de stage',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Bouton Ajouter Rapport
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddRapportScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Ajouter Rapport', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            // Bouton Consulter Rapport
            ElevatedButton(
              onPressed: () {
                // Placeholder pour la page de consultation
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const ConsultRapportScreen()),
                // );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Consulter Rapport', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
