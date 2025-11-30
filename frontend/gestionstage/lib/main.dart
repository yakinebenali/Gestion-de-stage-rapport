// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:gestionstage/acceuilEntreprise.dart';
import 'package:gestionstage/connexion.dart';
import 'package:gestionstage/inscription.dart';
import 'package:gestionstage/Acceuil.dart'; // Accueil étudiant

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Vérifier si l'utilisateur est déjà connecté
  final prefs = await SharedPreferences.getInstance();
final email = prefs.getString('email');
final role = prefs.getString('role');


  runApp(MyApp(
    isLoggedIn: email != null && role != null,
    role: role,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const MyApp({super.key, required this.isLoggedIn, this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn
          ? (role == 'etudiant'
              ? const AccueilPage()
              : const AccueilEntreprisePage()) // redirection entreprise
          : const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildButton(BuildContext context, String label, IconData icon, Widget page) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
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
                      buildButton(context, "Inscription", Icons.person_add_alt_1,
                          InscriptionPage()),
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
