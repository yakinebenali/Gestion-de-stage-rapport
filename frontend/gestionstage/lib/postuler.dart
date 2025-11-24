import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File;
import 'dart:typed_data'; // Pour web

class PostulerPage extends StatefulWidget {
  const PostulerPage({super.key});

  @override
  _PostulerPageState createState() => _PostulerPageState();
}

class _PostulerPageState extends State<PostulerPage> {
  final _formKey = GlobalKey<FormState>();
  String? _studentName;
  String? _offerId;
  String? _message;
  File? _cvFile; // mobile/desktop
  Uint8List? _cvBytes; // web
  String? _cvFileName;
  String? _errorMessage;

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          _cvBytes = result.files.single.bytes;
          _cvFileName = result.files.single.name;
          _cvFile = null;
        } else {
          _cvFile = File(result.files.single.path!);
          _cvFileName = result.files.single.name;
          _cvBytes = null;
        }
      });
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cvFile == null && _cvBytes == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner un CV PDF';
      });
      return;
    }

    _formKey.currentState!.save();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/Postuler'),
      );

      request.fields['student_name'] = _studentName!;
      request.fields['offer_id'] = _offerId!;
      request.fields['message'] = _message ?? '';

      if (kIsWeb && _cvBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'cv',
          _cvBytes!,
          filename: _cvFileName!,
        ));
      } else if (_cvFile != null) {
        request.files.add(await http.MultipartFile.fromPath('cv', _cvFile!.path, filename: _cvFileName!));
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Candidature envoyée avec succès!')),
        );
        setState(() {
          _formKey.currentState?.reset();
          _cvFile = null;
          _cvBytes = null;
          _cvFileName = null;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'envoi: ${response.statusCode}';
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
      appBar: AppBar(title: const Text('Postuler à une offre')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom de l\'étudiant'),
                validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                onSaved: (value) => _studentName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID de l\'offre'),
                validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                onSaved: (value) => _offerId = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Message (optionnel)'),
                maxLines: 3,
                onSaved: (value) => _message = value,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickCV,
                child: Text(_cvFileName == null ? 'Sélectionner un CV PDF' : 'CV: $_cvFileName'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitApplication,
                child: const Text('Envoyer la candidature'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
