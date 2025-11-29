import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
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
  File? cvFile;

  Future<void> pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        cvFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitCandidature() async {
    if (!_formKey.currentState!.validate() || cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs et choisir un CV')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/Postuler'),
    );

    request.fields['student_name'] = _nameController.text;
    request.fields['offer_id'] = widget.offreId.toString();
    request.fields['message'] = _messageController.text;
    request.files.add(await http.MultipartFile.fromPath('cv', cvFile!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Candidature envoyée !')),
      );
      _nameController.clear();
      _messageController.clear();
      setState(() {
        cvFile = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Postuler'), backgroundColor: Color(0xFF4285F4)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Entrez votre nom' : null,
              ),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Message'),
                validator: (value) => value!.isEmpty ? 'Entrez un message' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickCV,
                child: Text(cvFile == null ? 'Choisir CV (PDF)' : 'CV sélectionné'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitCandidature,
                child: Text('Envoyer Candidature'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
