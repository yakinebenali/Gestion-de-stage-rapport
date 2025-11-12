import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final url = Uri.parse('http://localhost:3000/getAllOffres'); // URL de ton backend
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des Offres')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: offres.length,
                  itemBuilder: (context, index) {
                    final offre = offres[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(offre['titre'] ?? 'Sans titre'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${offre['description'] ?? ''}'),
                            if (offre['duree'] != null) Text('Durée: ${offre['duree']}'),
                            if (offre['competences'] != null)
                              Text('Compétences: ${offre['competences']}'),
                            Text('Entreprise ID: ${offre['entreprise_id']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
