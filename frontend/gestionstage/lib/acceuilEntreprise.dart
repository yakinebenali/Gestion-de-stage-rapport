// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api, depend_on_referenced_packages, file_names

import 'package:flutter/material.dart';
import 'package:gestionstage/ajoutOffre.dart';
import 'package:gestionstage/consultOffre.dart';
import 'package:gestionstage/consult_candidature.dart';
import 'package:gestionstage/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccueilEntreprisePage extends StatefulWidget {
  const AccueilEntreprisePage({super.key});

  @override
  _AccueilEntreprisePageState createState() => _AccueilEntreprisePageState();
}

class _AccueilEntreprisePageState extends State<AccueilEntreprisePage> {
  int? entrepriseId;

  @override
  void initState() {
    super.initState();
    _loadEntrepriseId();
  }

Future<void> _loadEntrepriseId() async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getString('entreprise_id');
  if (id != null) {
    setState(() {
      entrepriseId = int.tryParse(id);
    });
    print("✅ ID de l'entreprise récupéré: $entrepriseId");
  } else {
    print("⚠️ Aucun ID entreprise trouvé dans SharedPreferences");
  }
}


  // 🔹 Fonction pour créer un bouton
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

  // 🔹 Fonction déconnexion
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // supprime les infos stockées
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Entreprise"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: entrepriseId == null
          ? const Center(child: CircularProgressIndicator()) // affichage pendant chargement
          : SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Bienvenue sur votre espace entreprise",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      buildButton(context, "Consulter Offres", Icons.business_center, OffresPage()),
                      const SizedBox(height: 20),
                      buildButton(
                        context,
                        "Ajouter Offre",
                        Icons.add_business,
                        AjouterOffrePage(entrepriseId: entrepriseId!),
                      ),
                      const SizedBox(height: 20),
                      buildButton(
                        context,
                        "Consulter Candidatures",
                        Icons.how_to_reg,
                        ConsultCandidatureScreen(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text("Déconnexion"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
                          backgroundColor: Colors.red.shade400,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
