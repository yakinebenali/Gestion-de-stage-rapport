import 'package:flutter/material.dart';
import 'package:gestionstage/ajoutRaport.dart';
import 'package:gestionstage/connexion.dart';
import 'package:gestionstage/consultRapport.dart';
import 'package:gestionstage/ajoutOffre.dart';
import 'package:gestionstage/consult_candidature.dart';
import 'package:gestionstage/consultOffre.dart';
import 'package:gestionstage/inscription.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildButton(BuildContext context, String label, IconData icon, Widget page) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: TextStyle(fontSize: 18)),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text(
                'Bienvenue dans l’application de gestion de stage',
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      buildButton(context, "Ajouter Rapport", Icons.note_add, AddRapportScreen()),
                      buildButton(context, "Consulter Rapport", Icons.notes, ConsultRapportScreen()),
                      buildButton(context, "Ajouter Offre", Icons.add_business, AjouterOffrePage(entrepriseId: 1)),
                      buildButton(context, "Consulter Offre", Icons.business_center, OffresPage()),
                      buildButton(context, "Consulter Candidatures", Icons.how_to_reg, ConsultCandidatureScreen()),
                      buildButton(context, "Inscription", Icons.person_add_alt_1, InscriptionPage()),
                      buildButton(context, "Connexion", Icons.login, ConnexionPage()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
