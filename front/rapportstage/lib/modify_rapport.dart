// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class ModifyRapportScreen extends StatefulWidget {
  final Map rapport;

  const ModifyRapportScreen({super.key, required this.rapport});

  @override
  _ModifyRapportScreenState createState() => _ModifyRapportScreenState();
}

class _ModifyRapportScreenState extends State<ModifyRapportScreen> {
  late TextEditingController titleController;
  late TextEditingController companyController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController descriptionController;
  late TextEditingController filiereController;

  PlatformFile? selectedPdf;
  bool _modified = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.rapport['title']);
    companyController = TextEditingController(text: widget.rapport['company']);
    startDateController = TextEditingController(text: widget.rapport['start_date']);
    endDateController = TextEditingController(text: widget.rapport['end_date']);
    descriptionController = TextEditingController(text: widget.rapport['description']);
    filiereController = TextEditingController(text: widget.rapport['filiere']);
startDateController = TextEditingController(text: _formatDate(widget.rapport['start_date']));
endDateController = TextEditingController(text: _formatDate(widget.rapport['end_date']));

    // 🔹 Détection modification
    titleController.addListener(_checkModified);
    companyController.addListener(_checkModified);
    startDateController.addListener(_checkModified);
    endDateController.addListener(_checkModified);
    descriptionController.addListener(_checkModified);
    filiereController.addListener(_checkModified);
  }

  void _checkModified() {
    bool modified = titleController.text != widget.rapport['title'] ||
        companyController.text != widget.rapport['company'] ||
        startDateController.text != widget.rapport['start_date'] ||
        endDateController.text != widget.rapport['end_date'] ||
        descriptionController.text != widget.rapport['description'] ||
        filiereController.text != widget.rapport['filiere'] ||
        selectedPdf != null;

    setState(() {
      _modified = modified;
    });
  }

  // 📌 Sélection PDF
  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        selectedPdf = result.files.first;
      });
      _checkModified();
    }
  }

  // 📌 Sélection date
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(controller.text);
      if (initialDate.isBefore(DateTime(2000))) initialDate = DateTime.now();
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = "${picked.year.toString().padLeft(4,'0')}-"
          "${picked.month.toString().padLeft(2,'0')}-"
          "${picked.day.toString().padLeft(2,'0')}";
      _checkModified();
    }
  }
String _formatDate(String dateTimeStr) {
  try {
    DateTime dt = DateTime.parse(dateTimeStr);
    return "${dt.year.toString().padLeft(4,'0')}-"
           "${dt.month.toString().padLeft(2,'0')}-"
           "${dt.day.toString().padLeft(2,'0')}";
  } catch (_) {
    return dateTimeStr;
  }
}

  // 📌 UPDATE
  Future<void> updateRapport() async {
    try {
      var request = http.MultipartRequest(
        "PUT",
        Uri.parse("http://localhost:3000/rapports/${widget.rapport['id']}"),
      );

      request.fields['title'] = titleController.text;
      request.fields['company'] = companyController.text;
      request.fields['start_date'] = startDateController.text;
      request.fields['end_date'] = endDateController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['filiere'] = filiereController.text;

      if (selectedPdf != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "pdf",
            selectedPdf!.bytes!,
            filename: selectedPdf!.name,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rapport modifié avec succès")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur serveur : ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier Rapport"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Titre")),
            TextField(controller: companyController, decoration: const InputDecoration(labelText: "Entreprise")),
            TextField(
              controller: startDateController,
              decoration: const InputDecoration(labelText: "Date début"),
              readOnly: true,
              onTap: () => _selectDate(context, startDateController),
            ),
            TextField(
              controller: endDateController,
              decoration: const InputDecoration(labelText: "Date fin"),
              readOnly: true,
              onTap: () => _selectDate(context, endDateController),
            ),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: filiereController, decoration: const InputDecoration(labelText: "Filière")),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(selectedPdf == null
                  ? "Changer le PDF"
                  : "PDF sélectionné : ${selectedPdf!.name}"),
              onPressed: pickPdf,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _modified ? updateRapport : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: const Text("Modifier"),
            ),
          ],
        ),
      ),
    );
  }
}
