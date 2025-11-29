import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;
import 'dart:typed_data';

class AddRapportScreen extends StatefulWidget {
  const AddRapportScreen({super.key});

  @override
  _AddRapportScreenState createState() => _AddRapportScreenState();
}

class _AddRapportScreenState extends State<AddRapportScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _company;
  String? _description;
  String? _filiere;

  // Controllers pour les dates
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  File? _pdfFile;
  Uint8List? _pdfBytes;
  String? _pdfFileName;

  String? _errorMessage;

  // ------------------------
  // 📌 Sélection du PDF
  // ------------------------
  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _pdfFileName = result.files.single.name;

        if (kIsWeb) {
          _pdfBytes = result.files.single.bytes;
          _pdfFile = null;
        } else {
          _pdfFile = File(result.files.single.path!);
          _pdfBytes = null;
        }
      });
    }
  }

  // ------------------------
  // 📌 Sélecteur de date
  // ------------------------
  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // ------------------------
  // 📌 Envoi au backend
  // ------------------------
  Future<void> addRapportWithPdf() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/AjoutRapport'),
      );

      request.fields['title'] = _title!;
      request.fields['company'] = _company!;
      request.fields['filiere'] = _filiere!;

      if (_startDateController.text.isNotEmpty) {
        request.fields['start_date'] = _startDateController.text;
      }
      if (_endDateController.text.isNotEmpty) {
        request.fields['end_date'] = _endDateController.text;
      }
      if (_description != null) {
        request.fields['description'] = _description!;
      }

      // PDF
      if (kIsWeb && _pdfBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes('pdf', _pdfBytes!, filename: _pdfFileName),
        );
      } else if (_pdfFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('pdf', _pdfFile!.path,
              filename: _pdfFileName),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rapport ajouté avec succès")),
        );

        setState(() {
          _formKey.currentState?.reset();
          _startDateController.clear();
          _endDateController.clear();
          _pdfBytes = null;
          _pdfFile = null;
          _pdfFileName = null;
        });
      } else {
        setState(() => _errorMessage = "Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _errorMessage = "Erreur : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un Rapport")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Titre
              TextFormField(
                decoration: const InputDecoration(labelText: "Titre"),
                validator: (v) => v!.isEmpty ? "Entrez un titre" : null,
                onSaved: (v) => _title = v,
              ),

              // Entreprise
              TextFormField(
                decoration: const InputDecoration(labelText: "Entreprise"),
                validator: (v) => v!.isEmpty ? "Entrez une entreprise" : null,
                onSaved: (v) => _company = v,
              ),

              // Filière
              TextFormField(
                decoration: const InputDecoration(labelText: "Filière"),
                validator: (v) => v!.isEmpty ? "Entrez une filière" : null,
                onSaved: (v) => _filiere = v,
              ),

              const SizedBox(height: 15),

              // 📌 Date début (avec calendrier)
              InkWell(
                onTap: () => _selectDate(_startDateController),
                child: TextFormField(
                  controller: _startDateController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Date début",
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 📌 Date fin (avec calendrier)
              InkWell(
                onTap: () => _selectDate(_endDateController),
                child: TextFormField(
                  controller: _endDateController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Date fin",
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Description
              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                onSaved: (v) => _description = v,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _pickPdf,
                child: Text(_pdfFileName == null
                    ? "Sélectionner un PDF"
                    : "PDF : $_pdfFileName"),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_pdfFile == null && _pdfBytes == null) {
                      setState(() => _errorMessage = "Choisissez un PDF");
                      return;
                    }
                    _formKey.currentState!.save();
                    await addRapportWithPdf();
                  }
                },
                child: const Text("Ajouter Rapport"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
