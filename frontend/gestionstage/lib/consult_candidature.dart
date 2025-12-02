// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsultCandidatureScreen extends StatefulWidget {
  const ConsultCandidatureScreen({super.key});

  @override
  _ConsultCandidatureScreenState createState() =>
      _ConsultCandidatureScreenState();
}

class _ConsultCandidatureScreenState extends State<ConsultCandidatureScreen> {
  List<dynamic> _candidatures = [];
  bool _isLoading = true;
  String? _errorMessage;

  final String backendUrl = "http://localhost:3000";
  int? entrepriseId;

  @override
  void initState() {
    super.initState();
    _loadEntreprise();
  }

  /// Chargement de l’ID entreprise depuis SharedPreferences
  Future<void> _loadEntreprise() async {
    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString("entreprise_id");

    if (idString == null) {
      setState(() {
        _errorMessage = "Impossible de charger l’entreprise.";
        _isLoading = false;
      });
      return;
    }

    entrepriseId = int.tryParse(idString);

    if (entrepriseId == null) {
      setState(() {
        _errorMessage = "ID entreprise invalide.";
        _isLoading = false;
      });
      return;
    }

    _fetchCandidatures();
  }

  /// Récupération des candidatures
  Future<void> _fetchCandidatures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = "$backendUrl/Candidatures?entreprise_id=$entrepriseId";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _candidatures = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Erreur lors du chargement : ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur : $e";
        _isLoading = false;
      });
    }
  }

  /// Ouvrir le PDF
  Future<void> _openPdf(String pdfPath) async {
    final url = pdfPath.startsWith('http') ? pdfPath : "$backendUrl$pdfPath";
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le CV")),
      );
    }
  }

  /// Popup de confirmation
  Future<void> _showConfirmationDialog(int id, String action) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'acceptee' ? 'Accepter' : 'Refuser'),
        content: Text(action == 'acceptee'
            ? 'Voulez-vous accepter cette candidature ?'
            : 'Voulez-vous refuser cette candidature ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action == 'acceptee' ? 'Accepter' : 'Refuser'),
          ),
        ],
      ),
    );

    if (confirm) {
      _updateCandidature(id, action);
    }
  }

  /// Mise à jour du statut
  Future<void> _updateCandidature(int id, String action) async {
    try {
      final response = await http.put(
        Uri.parse('$backendUrl/Candidatures/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": action}), // acceptee / refusee
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'acceptee'
                  ? 'Candidature acceptée'
                  : 'Candidature refusée',
            ),
            backgroundColor: action == 'acceptee' ? Colors.green : Colors.red,
          ),
        );
        _fetchCandidatures();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulter les Candidatures"),
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
              : _candidatures.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucune candidature trouvée",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchCandidatures,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _candidatures.length,
                        itemBuilder: (context, index) {
                          final c = _candidatures[index];
                          final studentName = c["student_name"] ?? "Sans nom";
                          final offerId = c["offer_id"] ?? "N/A";
                          final message = c["message"] ?? "";
                          final status = c["status"] ?? "en_attente";

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studentName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text("Offre ID: $offerId"),
                                        if (message.isNotEmpty)
                                          Text("Message: $message"),
                                        Text("Status : $status"),
                                      ],
                                    ),
                                  ),

                                  /// BOUTONS ACCEPT / REFUSE
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: status == "en_attente"
                                        ? [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _showConfirmationDialog(
                                                      c["id"], 'acceptee'),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green),
                                              child: const Text('Accepter'),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _showConfirmationDialog(
                                                      c["id"], 'refusee'),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              child: const Text('Refuser'),
                                            ),
                                          ]
                                        : [],
                                  ),

                                  if (c["cv_path"] != null)
                                    IconButton(
                                      icon: const Icon(Icons.picture_as_pdf),
                                      onPressed: () => _openPdf(c["cv_path"]),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
