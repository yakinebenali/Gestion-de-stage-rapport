import 'package:flutter/foundation.dart' show kIsWeb; // Ajout pour vérifier la plateforme
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File, Platform; // Importation conditionnelle pour non-web
import 'dart:typed_data'; // Pour Uint8List (bytes)

class AddRapportScreen extends StatefulWidget {
  const AddRapportScreen({super.key});

  @override
  _AddRapportScreenState createState() => _AddRapportScreenState();
}

class _AddRapportScreenState extends State<AddRapportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title, _company, _startDate, _endDate, _description;
  File? _pdfFile; // Utilisé pour mobile/desktop
  Uint8List? _pdfBytes; // Utilisé pour web
  String? _pdfFileName; // Nom du fichier pour affichage et envoi
  String? _errorMessage;

  // Fonction pour sélectionner un fichier PDF
 Future<void> _pickPdf() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (result != null) {
    print('Fichier sélectionné: ${result.files.single.name}, Type MIME: ${result.files.single.extension}');
    setState(() {
      if (kIsWeb) {
        _pdfBytes = result.files.single.bytes;
        _pdfFileName = result.files.single.name;
        _pdfFile = null;
      } else {
        _pdfFile = File(result.files.single.path!);
        _pdfFileName = result.files.single.name;
        _pdfBytes = null;
      }
    });
  }
}
  // Fonction pour envoyer le rapport au backend
  Future<void> addRapportWithPdf({
    required String title,
    required String company,
    String? startDate,
    String? endDate,
    String? description,
    File? pdfFile, // Utilisé pour mobile/desktop
    Uint8List? pdfBytes, // Utilisé pour web
    required String pdfFileName, // Nom du fichier
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/AjoutRapport'),
      );

      // Ajouter les champs texte
      request.fields['title'] = title;
      request.fields['company'] = company;
      if (startDate != null) request.fields['start_date'] = startDate;
      if (endDate != null) request.fields['end_date'] = endDate;
      if (description != null) request.fields['description'] = description;

      // Ajouter le fichier PDF
      if (kIsWeb) {
        if (pdfBytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'pdf',
            pdfBytes,
            filename: pdfFileName,
          ));
        }
      } else {
        if (pdfFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'pdf',
            pdfFile.path,
            filename: pdfFileName,
          ));
        }
      }

      // Envoyer la requête
      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapport ajouté avec succès')),
        );
        setState(() {
          _formKey.currentState?.reset();
          _pdfFile = null;
          _pdfBytes = null;
          _pdfFileName = null;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'ajout du rapport: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Rapport')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Champ Titre
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
                onSaved: (value) => _title = value,
              ),
              // Champ Entreprise
              TextFormField(
                decoration: const InputDecoration(labelText: 'Entreprise'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une entreprise';
                  }
                  return null;
                },
                onSaved: (value) => _company = value,
              ),
              // Champ Date de début
              TextFormField(
                decoration: const InputDecoration(labelText: 'Date de début (YYYY-MM-DD)'),
                onSaved: (value) => _startDate = value!.isEmpty ? null : value,
              ),
              // Champ Date de fin
              TextFormField(
                decoration: const InputDecoration(labelText: 'Date de fin (YYYY-MM-DD)'),
                onSaved: (value) => _endDate = value!.isEmpty ? null : value,
              ),
              // Champ Description
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!.isEmpty ? null : value,
              ),
              const SizedBox(height: 16),
              // Bouton pour sélectionner le PDF
              ElevatedButton(
                onPressed: _pickPdf,
                child: Text(_pdfFileName == null
                    ? 'Sélectionner un PDF'
                    : 'PDF: $_pdfFileName'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              // Bouton pour soumettre
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_pdfFile == null && _pdfBytes == null) {
                      setState(() {
                        _errorMessage = 'Veuillez sélectionner un fichier PDF';
                      });
                      return;
                    }
                    _formKey.currentState!.save();
                    await addRapportWithPdf(
                      title: _title!,
                      company: _company!,
                      startDate: _startDate,
                      endDate: _endDate,
                      description: _description,
                      pdfFile: _pdfFile,
                      pdfBytes: _pdfBytes,
                      pdfFileName: _pdfFileName ?? 'rapport.pdf',
                    );
                  }
                },
                child: const Text('Ajouter Rapport'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}