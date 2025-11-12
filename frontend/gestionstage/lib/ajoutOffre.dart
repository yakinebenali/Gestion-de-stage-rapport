import 'package:flutter/material.dart';
import 'package:gestionstage/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AjouterOffrePage extends StatefulWidget {
  @override
  _AjouterOffrePageState createState() => _AjouterOffrePageState();
}

class _AjouterOffrePageState extends State<AjouterOffrePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dureeController = TextEditingController();
  final TextEditingController competencesController = TextEditingController();
  final TextEditingController entrepriseIdController = TextEditingController();

  String message = '';

  Future<void> ajouterOffre() async {
    final url = Uri.parse('http://localhost:3000/ajouteroffre'); // URL de ton backend
    final body = {
      "titre": titreController.text,
      "description": descriptionController.text,
      "duree": dureeController.text,
      "competences": competencesController.text,
      "entreprise_id": int.tryParse(entrepriseIdController.text) ?? 0
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);

     if (response.statusCode == 201) {
  // Affiche le message avant de naviguer
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Offre ajoutée avec succès ! ID: ${result['offre']['id']}'),
      duration: Duration(seconds: 2), // Affiche pendant 2 secondes
    ),
  );

  // Attend que le SnackBar soit visible avant de naviguer
  await Future.delayed(Duration(seconds: 2));

  // Navigue vers la page principale (MainPage ou HomePage)
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()), // Remplace MyApp par ta page principale
  );
}
else {
        // Erreur : afficher le message
        setState(() {
          message = "Erreur: ${result['error']}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Erreur serveur: $e";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une Offre')),
      body: Padding(
        padding: EdgeInsets.all(16),
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
                ),
                TextFormField(
                  controller: dureeController,
                  decoration: InputDecoration(labelText: 'Durée'),
                ),
                TextFormField(
                  controller: competencesController,
                  decoration: InputDecoration(labelText: 'Compétences'),
                ),
                TextFormField(
                  controller: entrepriseIdController,
                  decoration: InputDecoration(labelText: 'ID Entreprise'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ajouterOffre();
                    }
                  },
                  child: Text('Ajouter Offre'),
                ),
                SizedBox(height: 20),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                        color: message.contains('succès') ? Colors.green : Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
