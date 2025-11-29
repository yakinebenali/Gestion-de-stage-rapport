import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AjouterOffrePage extends StatefulWidget {
  final int entrepriseId; // ID récupéré automatiquement

  const AjouterOffrePage({super.key, required this.entrepriseId});

  @override
  _AjouterOffrePageState createState() => _AjouterOffrePageState();
}

class _AjouterOffrePageState extends State<AjouterOffrePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dureeController = TextEditingController();
  final TextEditingController competencesController = TextEditingController();

  String message = '';

  Future<void> ajouterOffre() async {
    final url = Uri.parse('http://localhost:3000/ajouteroffre?entreprise_id=${widget.entrepriseId}');

    final body = {
      "titre": titreController.text,
      "description": descriptionController.text,
      "duree": dureeController.text,
      "competences": competencesController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Offre ajoutée avec succès !"),
            duration: Duration(seconds: 2),
          ),
        );

        // Attendre avant navigation
        await Future.delayed(Duration(seconds: 2));

        Navigator.pop(context); // Retourne à la page entreprise
      } else {
        setState(() {
          message = "Erreur : ${result['error']}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Erreur serveur : $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une Offre')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: titreController,
                  decoration: InputDecoration(labelText: 'Titre'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  maxLines: 3,
                ),
                TextFormField(
                  controller: dureeController,
                  decoration: InputDecoration(labelText: 'Durée'),
                ),
                TextFormField(
                  controller: competencesController,
                  decoration: InputDecoration(labelText: 'Compétences'),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ajouterOffre();
                    }
                  },
                  child: const Text('Ajouter Offre'),
                ),

                const SizedBox(height: 15),

                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
