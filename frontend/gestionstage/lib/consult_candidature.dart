import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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

  // ⚠️ Remplacez par l'IP de votre PC si nécessaire
  final String backendUrl = "http://localhost:3000";

  @override
  void initState() {
    super.initState();
    _fetchCandidatures();
  }

  Future<void> _fetchCandidatures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse("$backendUrl/Candidatures"));
      if (response.statusCode == 200) {
        setState(() {
          _candidatures = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Erreur lors du chargement: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur: $e";
        _isLoading = false;
      });
    }
  }

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

  // Dialogue de confirmation pour accepter ou refuser
  Future<void> _showConfirmationDialog(int id, String action) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'accepter' ? 'Accepter' : 'Refuser'),
        content: Text(action == 'accepter'
            ? 'Voulez-vous accepter cette candidature ?'
            : 'Êtes-vous sûr de refuser cette candidature ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action == 'accepter' ? 'Accepter' : 'Refuser'),
          ),
        ],
      ),
    );

    if (confirm) {
      _updateCandidature(id, action);
    }
  }

  Future<void> _updateCandidature(int id, String action) async {
    try {
      final response = await http.put(
        Uri.parse('$backendUrl/Candidatures/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": action}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Candidature ${action == 'accepter' ? 'acceptée' : 'refusée'}'),
            backgroundColor: action == 'accepter' ? Colors.green : Colors.red,
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
                ))
              : _candidatures.isEmpty
                  ? const Center(
                      child: Text(
                      "Aucune candidature trouvée",
                      style: TextStyle(fontSize: 20),
                    ))
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
                          final status = c["status"] ?? "en attente";

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
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: status == "en attente"
                                        ? [
                                            SizedBox(
                                              width: 70,
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _showConfirmationDialog(
                                                        c["id"], 'accepter'),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    padding: EdgeInsets.zero),
                                                child: const Text(
                                                  'Accepter',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              width: 70,
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _showConfirmationDialog(
                                                        c["id"], 'refuser'),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    padding: EdgeInsets.zero),
                                                child: const Text(
                                                  'Refuser',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
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
