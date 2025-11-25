import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'postuler.dart';

class OffresPage extends StatefulWidget {
  @override
  _OffresPageState createState() => _OffresPageState();
}

class _OffresPageState extends State<OffresPage> {
  List offres = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOffres();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6ECF5), //  accueil
      appBar: AppBar(
        backgroundColor: Color(0xFF4285F4), //  accueil
        title: Text('Liste des Offres'),
        centerTitle: true,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
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

                            // -------  postuler  accueil -------
                            customButton(
                              "Postuler à cette offre",
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostulerPage(offreId: offre['id']),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
