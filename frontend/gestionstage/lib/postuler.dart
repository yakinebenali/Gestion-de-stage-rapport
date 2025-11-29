import 'dart:typed_data';
import 'dart:io' show File; // ignore on web
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';

class PostulerPage extends StatefulWidget {
  final int offreId;
  PostulerPage({required this.offreId});

  @override
  _PostulerPageState createState() => _PostulerPageState();
}

class _PostulerPageState extends State<PostulerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  File? cvFile;               // Mobile
  Uint8List? cvBytes;         // Web
  String? cvFileName;         // Nom du fichier

  // ------------------------ PICKER ------------------------
  Future<void> pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // IMPORTANT pour web
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          cvBytes = result.files.first.bytes;
          cvFileName = result.files.first.name;
        } else {
          cvFile = File(result.files.first.path!);
        }
      });
    }
  }

  // ------------------------ SUBMIT ------------------------
  Future<void> submitCandidature() async {
    if (_nameController.text.isEmpty ||
        _messageController.text.isEmpty ||
        (cvFile == null && cvBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs et choisir un CV")),
      );
      return;
    }

    var uri = Uri.parse("http://localhost:3000/Postuler");
    var request = http.MultipartRequest("POST", uri);

    request.fields["student_name"] = _nameController.text;
    request.fields["offer_id"] = widget.offreId.toString();
    request.fields["message"] = _messageController.text;

    // ------------ GESTION WEB ------------
    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "pdf",        // DOIT matcher upload.single("pdf")
          cvBytes!,
          filename: cvFileName!,
          contentType: MediaType('application', 'pdf'),
        ),
      );
    }
    // ------------ GESTION MOBILE ------------
    else {
      request.files.add(
        await http.MultipartFile.fromPath(
          "pdf",
          cvFile!.path,
          contentType: MediaType('application', 'pdf'),
        ),
      );
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Candidature envoyée avec succès !")),
      );

      _nameController.clear();
      _messageController.clear();
      setState(() {
        cvFile = null;
        cvBytes = null;
        cvFileName = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'envoi | Code : ${response.statusCode}")),
      );
    }
  }

  // ------------------------ UI ------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postuler'),
        backgroundColor: Color(0xFF4285F4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (v) => v!.isEmpty ? "Entrez votre nom" : null,
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Message'),
                validator: (v) => v!.isEmpty ? "Entrez un message" : null,
                maxLines: 4,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: pickCV,
                child: Text(
                  cvFile != null || cvBytes != null
                      ? "CV sélectionné ✔️"
                      : "Choisir CV (PDF)",
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: submitCandidature,
                child: Text("Envoyer Candidature"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
