import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddOffreScreen extends StatefulWidget {
  final int entrepriseId; // ID de l'entreprise connectée
  const AddOffreScreen({super.key, required this.entrepriseId});

  @override
  _AddOffreScreenState createState() => _AddOffreScreenState();
}

class _AddOffreScreenState extends State<AddOffreScreen> {
  final _formKey = GlobalKey<FormState>();
  final titreController = TextEditingController();
  final descriptionController = TextEditingController();
  final dureeController = TextEditingController();
  final competencesController = TextEditingController();

  Future<void> ajouterOffre() async {
    final url = Uri.parse('http://localhost:3000/ajouteroffre');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'titre': titreController.text,
        'description': descriptionController.text,
        'duree': dureeController.text,
        'competences': competencesController.text,
        'entreprise_id': widget.entrepriseId,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Offre ajoutée avec succès')),
      );
      titreController.clear();
      descriptionController.clear();
      dureeController.clear();
      competencesController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Erreur: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une offre')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titreController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: dureeController,
                decoration: const InputDecoration(labelText: 'Durée'),
              ),
              TextFormField(
                controller: competencesController,
                decoration: const InputDecoration(labelText: 'Compétences'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: ajouterOffre,
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
