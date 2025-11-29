import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ConsultRapportScreen extends StatefulWidget {
  const ConsultRapportScreen({super.key});

  @override
  _ConsultRapportScreenState createState() => _ConsultRapportScreenState();
}

class _ConsultRapportScreenState extends State<ConsultRapportScreen> {
  List<dynamic> _rapports = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRapports();
  }

  // Fonction pour récupérer les rapports depuis le backend
  Future<void> _fetchRapports() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/Rapports'));
      if (response.statusCode == 200) {
        setState(() {
          _rapports = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des rapports: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  // Fonction pour ouvrir le PDF dans le navigateur
  Future<void> _openPdf(String pdfPath) async {
    final url = 'http://localhost:3000$pdfPath';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le PDF')),
      );
    }
  }

  // Fonction pour supprimer un rapport avec confirmation
  Future<void> _deleteRapport(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer ce rapport ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm) {
      try {
        final response = await http.delete(Uri.parse('http://localhost:3000/Rapports/$id'));
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rapport supprimé avec succès')),
          );
          _fetchRapports(); // Rafraîchir la liste
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur suppression: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulter les Rapports'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              : _rapports.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun rapport disponible',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _rapports.length,
                      itemBuilder: (context, index) {
                        final rapport = _rapports[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              rapport['title'] ?? 'Sans titre',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Entreprise: ${rapport['company'] ?? 'N/A'}'),
                                if (rapport['start_date'] != null)
                                  Text('Début: ${rapport['start_date']}'),
                                if (rapport['end_date'] != null)
                                  Text('Fin: ${rapport['end_date']}'),
                                if (rapport['description'] != null)
                                  Text('Description: ${rapport['description']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (rapport['pdf_path'] != null)
                                  IconButton(
                                    icon: const Icon(Icons.picture_as_pdf),
                                    onPressed: () => _openPdf(rapport['pdf_path']),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteRapport(rapport['id']),
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
