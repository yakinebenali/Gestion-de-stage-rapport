// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:gestionstage/gestionRapport.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil Étudiant"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Bienvenue sur votre espace étudiant",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 22, 0, 0),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GestionRapportPage(), 
                      ),
                    );
                  },
                  icon: Icon(Icons.note_add, size: 28),
                  label: Text(
                    "Gestion Rapport",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 6,
                  ),
                ),

                SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // pour revenir en arrière
                  },
                  icon: Icon(Icons.logout),
                  label: Text("Déconnexion"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 25),
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
