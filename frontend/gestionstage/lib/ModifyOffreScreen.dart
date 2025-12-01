// modify_offre_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ModifyOffreScreen extends StatefulWidget {
  final Map<String, dynamic> offre;
  // Constructor requiring the existing 'offre' data
  const ModifyOffreScreen({super.key, required this.offre}); 

  @override
  _ModifyOffreScreenState createState() => _ModifyOffreScreenState();
}

class _ModifyOffreScreenState extends State<ModifyOffreScreen> {
  // --- Controllers pour les champs du formulaire ---
  late TextEditingController titreController;
  late TextEditingController descriptionController;
  late TextEditingController dureeController;
  late TextEditingController competencesController;

  bool isSaving = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs avec les données existantes
    titreController = TextEditingController(text: widget.offre['titre'] ?? '');
    descriptionController = TextEditingController(
      text: widget.offre['description'] ?? '',
    );
    // Convertir la durée en chaîne pour le champ de texte
    dureeController = TextEditingController(
      text: widget.offre['duree']?.toString() ?? '',
    ); 
    competencesController = TextEditingController(
      text: widget.offre['competences'] ?? '',
    );
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    dureeController.dispose();
    competencesController.dispose();
    super.dispose();
  }

  Future<void> _saveModification() async {
    final id = widget.offre['id'];
    
    // ⚠️ IMPORTANT : Utilisez l'adresse IP de loopback de l'émulateur Android (10.0.2.2) 
    // ou l'adresse de votre machine si vous utilisez un appareil physique. 
    // 'localhost' fonctionne uniquement pour iOS Simulator ou Desktop.
    const baseUrl = 'http://localhost:3000'; 
    final url = Uri.parse('$baseUrl/ModifierOffre/$id');

    if (titreController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      setState(() => message = 'Titre et description sont requis');
      return;
    }

    setState(() {
      isSaving = true;
      message = '';
    });

    final body = {
      "titre": titreController.text.trim(),
      "description": descriptionController.text.trim(),
      // Assurer que la durée est un nombre si c'est ce qu'attend le backend
"duree": dureeController.text.trim(),
      "competences": competencesController.text.trim(),
    };

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Succès : Afficher un message et retourner à l'écran précédent
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offre modifiée avec succès'))
            );
            await Future.delayed(const Duration(milliseconds: 600));
            Navigator.pop(context, true); 
        }
      } else {
        // Erreur : Tenter de décoder le message d'erreur du backend
        String err = 'Erreur lors de la modification (${response.statusCode})';
        try {
          final res = jsonDecode(response.body);
          if (res is Map && res['error'] != null) err = res['error'];
        } catch (_) {
          // Si le corps de la réponse n'est pas du JSON valide
          err = 'Erreur: Le serveur a répondu ${response.statusCode}.';
        }
        setState(() => message = err);
      }
    } catch (e) {
      // Erreur réseau (timeout, serveur injoignable, etc.)
      setState(() => message = 'Erreur réseau: Vérifiez que le serveur est lancé (http://localhost:3000). Détail: $e');
    } finally {
      // S'assurer que le bouton est réactivé
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'offre'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(message, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            TextField(
              controller: titreController,
              decoration: const InputDecoration(labelText: 'Titre', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dureeController,
              decoration: const InputDecoration(labelText: 'Durée (en mois/jours)', border: OutlineInputBorder()),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
              TextField(
              controller: competencesController,
              decoration: const InputDecoration(labelText: 'Compétences (séparées par des virgules)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSaving ? null : _saveModification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Enregistrer la Modification', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}