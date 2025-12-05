// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:rapportstage/gestionRapport.dart';
import 'package:rapportstage/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  // Fonction pour déconnexion
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // supprime toutes les infos de connexion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Étudiant"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Bienvenue sur votre espace étudiant",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 22, 0, 0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GestionRapportPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.note_add, size: 28),
                label: const Text(
                  "Gestion Rapport",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 30),
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 6,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => logout(context),
                icon: const Icon(Icons.logout),
                label: const Text("Déconnexion"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
