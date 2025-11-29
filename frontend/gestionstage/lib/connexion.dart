import 'package:flutter/material.dart';
import 'package:gestionstage/Acceuil.dart';
import 'package:gestionstage/inscription.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestionstage/main.dart';

class ConnexionPage extends StatefulWidget {
  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mdpController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

 Future<void> loginUser() async {
  final email = emailController.text.trim();
  final motDePasse = mdpController.text.trim();

  if (email.isEmpty || motDePasse.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Veuillez remplir tous les champs")),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    final url = Uri.parse("http://localhost:3000/connexion");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "mot_de_passe": motDePasse,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      String role = data["role"]; // ⚡ récupérer le rôle depuis le serveur

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connexion réussie")),
      );

      if (role == "etudiant") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccueilPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["error"] ?? "Erreur de connexion")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur réseau : $e")),
    );
  }

  setState(() => isLoading = false);
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
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
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
                  Icon(Icons.lock_outline,
                      size: 70, color: Colors.blue.shade700),
                  SizedBox(height: 15),
                  Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Champ email
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Champ mot de passe
                  TextField(
                    controller: mdpController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                  SizedBox(height: 30),

                  // Bouton connexion
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.blue.shade700,
                          ),
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),

                  SizedBox(height: 15),

                  GestureDetector(
                     onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InscriptionPage()),
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
