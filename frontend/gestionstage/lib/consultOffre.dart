// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestionstage/ajoutOffre.dart';
import 'package:gestionstage/ModifyOffreScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'postuler.dart';

class OffresPage extends StatefulWidget {
  const OffresPage({super.key});

  @override
  _OffresPageState createState() => _OffresPageState();
}

class _OffresPageState extends State<OffresPage> {
  int? entrepriseId;
  List offres = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOffres();
    _loadEntrepriseId();
  }

  Future<void> fetchOffres() async {
    final url = Uri.parse('http://localhost:3000/getAllOffres');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          offres = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur serveur: $e';
        isLoading = false;
      });
    }
  }

  // ----- accueil -----
  Widget customButton(String text, VoidCallback onPressed) {
    return Container(
      width: 250,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6ECF5), // accueil
      appBar: AppBar(
        backgroundColor: Color(0xFF4285F4),
        title: Text('Liste des Offres'),
        centerTitle: true,
      ),

      // 🔹 Bouton + en bas à droite
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, size: 30, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AjouterOffrePage(entrepriseId: entrepriseId!),
            ),
          ).then((value) {
            // si tu veux rafraichir la liste après ajout
            if (value == true) {
              fetchOffres(); // adapte le nom de la fonction si nécessaire
            }
          });
        },
      ),

      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(
                child: Text(errorMessage, style: TextStyle(color: Colors.red)),
              )
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: offres.length,
                itemBuilder: (context, index) {
                  final offre = offres[index];

                  return Card(
                    color: Colors.white.withOpacity(0.85),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offre['titre'] ?? 'Sans titre',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Description : ${offre['description'] ?? ''}"),
                          if (offre['duree'] != null)
                            Text("Durée : ${offre['duree']}"),
                          if (offre['competences'] != null)
                            Text("Compétences : ${offre['competences']}"),
                          Text("Entreprise ID : ${offre['entreprise_id']}"),
                          SizedBox(height: 16),

                          // Postuler button
                          customButton("Postuler à cette offre", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PostulerPage(offreId: offre['id']),
                              ),
                            );
                          }),

                          SizedBox(height: 8),

                          // Row for Edit and Delete icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () async {
                                  final updated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              ModifyOffreScreen(offre: offre),
                                    ),
                                  );
                                  if (updated == true) {
                                    fetchOffres();
                                  }
                                },
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  // confirmation avant suppression (recommandé)
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: Text('Confirmer'),
                                          content: Text(
                                            'Voulez-vous supprimer cette offre ?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: Text('Annuler'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: Text('Supprimer'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    await _deleteOffre(
                                      offre['id'],
                                    ); // ta fonction de suppression
                                    fetchOffres(); // rafraîchir la liste
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

Future<void> _deleteOffre(int id) async {
  final url = Uri.parse('http://localhost:3000/SupprimerOffre/$id');
  print('Deleting offer $id -> $url');

  try {
    final response = await http.delete(url);
    print('Response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        offres.removeWhere((offre) => offre['id'] == id);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Offre supprimée avec succès')));
    await fetchOffres();
    } else {
      String errorMsg = 'Erreur lors de la suppression (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['error'] != null) errorMsg = body['error'];
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  } catch (e) {
    print('Network error: $e');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Erreur réseau: $e')));
  }
}

}
