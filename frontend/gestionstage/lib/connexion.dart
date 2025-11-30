// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:gestionstage/Acceuil.dart';
import 'package:gestionstage/acceuilEntreprise.dart';
import 'package:gestionstage/inscription.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mdpController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  // 🔹 Vérifier si utilisateur déjà connecté
  Future<void> _checkIfAlreadyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    if (role != null) {
      if (role == 'etudiant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccueilPage()),
        );
      } else if (role == 'entreprise') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccueilEntreprisePage()),
        );
      }
    }
  }

  // 🔹 Sauvegarde infos de connexion
  Future<void> saveLoginInfo(String email, String role, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    if (role == 'entreprise') {
      await prefs.setString('entreprise_id', id);
    } else if (role == 'etudiant') {
      await prefs.setString('etudiant_id', id);
    }
    print("🔹 Connexion réussie");
    print("Email: $email");
    print("Role: $role");
    print("ID: $id");
  }

  // 🔹 Fonction connexion
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final motDePasse = mdpController.text.trim();

    if (email.isEmpty || motDePasse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("http://localhost:3000/connexion");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "mot_de_passe": motDePasse}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String role = data["role"];
        String id = data["user"]["id"].toString();

        // 🔹 Sauvegarde des infos
        await saveLoginInfo(email, role, id);

        // 🔹 Affichage message succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connexion réussie")),
          );
        }

        // 🔹 Navigation selon rôle
        if (mounted) {
          if (role == "etudiant") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AccueilPage()),
            );
          } else if (role == "entreprise") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AccueilEntreprisePage()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["error"] ?? "Erreur de connexion")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur réseau : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade800, Colors.blue.shade400],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 70,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Champ email
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Champ mot de passe
                  TextField(
                    controller: mdpController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => hidePassword = !hidePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Bouton connexion
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.blue.shade700,
                          ),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InscriptionPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Créer un compte",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
