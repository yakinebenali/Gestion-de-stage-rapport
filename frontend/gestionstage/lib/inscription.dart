// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'connexion.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nom = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController motDePasse = TextEditingController();
  final TextEditingController telephone = TextEditingController();
  final TextEditingController prenom = TextEditingController();
  final TextEditingController niveau = TextEditingController();
  final TextEditingController specialite = TextEditingController();
  final TextEditingController adresse = TextEditingController();

  String role = "etudiant";
  String message = "";
  bool hidePassword = true;
  bool isLoading = false;

  Future<void> inscrire() async {
    setState(() => isLoading = true);

    final url = Uri.parse("http://10.0.2.2:3000/inscription"); // Pour émulateur Android

    Map<String, dynamic> data = {
      "role": role,
      "nom": nom.text,
      "email": email.text,
      "mot_de_passe": motDePasse.text,
      "telephone": telephone.text,
    };

    if (role == "etudiant") {
      data.addAll({
        "prenom": prenom.text,
        "niveau": niveau.text,
        "specialite": specialite.text,
      });
    } else if (role == "entreprise") {
      data.addAll({"adresse": adresse.text});
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Inscription réussie !"), backgroundColor: Colors.green),
        );

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ConnexionPage()),
          );
        });
      } else {
        setState(() {
          message = "Erreur : ${result['error']}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Erreur serveur : $e";
      });
    }

    setState(() => isLoading = false);
  }

  Widget champ(String label, TextEditingController controller,
      {bool isPassword = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? hidePassword : false,
        validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(Icons.person_add_alt_1,
                        size: 80, color: Colors.blue.shade700),
                    SizedBox(height: 16),
                    Text(
                      "Créer un compte",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700),
                    ),
                    SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: InputDecoration(
                        labelText: "Choisir un rôle",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      items: const [
                        DropdownMenuItem(value: "etudiant", child: Text("Étudiant")),
                        DropdownMenuItem(value: "entreprise", child: Text("Entreprise")),
                      ],
                      onChanged: (value) => setState(() => role = value!),
                    ),

                    SizedBox(height: 20),

                    champ("Nom", nom, icon: Icons.person),
                    champ("Email", email, icon: Icons.email),
                    champ("Mot de passe", motDePasse, isPassword: true, icon: Icons.lock),
                    champ("Téléphone", telephone, icon: Icons.phone),

                    if (role == "etudiant") ...[
                      champ("Prénom", prenom, icon: Icons.person_outline),
                      champ("Niveau", niveau, icon: Icons.school),
                      champ("Spécialité", specialite, icon: Icons.work),
                    ],

                    if (role == "entreprise") ...[
                      champ("Adresse", adresse, icon: Icons.location_city),
                    ],

                    SizedBox(height: 20),

                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                inscrire();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(
                              "S'inscrire",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),

                    SizedBox(height: 15),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ConnexionPage()),
                        );
                      },
                      child: Text(
                        "Déjà un compte ? Se connecter",
                        style: TextStyle(
                            color: Colors.blue.shade700,
                            decoration: TextDecoration.underline),
                      ),
                    ),

                    if (message.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        message,
                        style: TextStyle(
                          color: message.contains("réussie") ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
