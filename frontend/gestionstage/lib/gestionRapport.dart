// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'ajoutRaport.dart';
import 'consultRapport.dart';

class GestionRapportPage extends StatelessWidget {
  const GestionRapportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des Rapports"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: ConsultRapportScreen(), // Affiche la liste des rapports
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRapportScreen()),
          );
        },
        backgroundColor: Colors.blue.shade700,
        tooltip: "Ajouter un rapport",
        child: Icon(Icons.add),
      ),
    );
  }
}
