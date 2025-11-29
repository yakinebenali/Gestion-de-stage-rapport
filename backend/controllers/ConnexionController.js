const bcrypt = require('bcrypt');
const connection = require('../BD/db');

// 🔐 Connexion utilisateur
const Connexion = async (req, res) => {
  const { email, mot_de_passe } = req.body;

  if (!email || !mot_de_passe) {
    return res.status(400).json({ error: "Tous les champs sont obligatoires" });
  }

  try {
    // Vérifier si c'est un étudiant
    const [etudiant] = await connection.query(
      "SELECT * FROM etudiants WHERE email = ?",
      [email]
    );

    if (etudiant.length > 0) {
      const user = etudiant[0];
      const correct = await bcrypt.compare(mot_de_passe, user.mot_de_passe);

      if (!correct) {
        return res.status(401).json({ error: "Mot de passe incorrect" });
      }

      return res.status(200).json({
        message: "Connexion réussie",
        role: "etudiant",       // ⚡ changer type → role
        user: {
          id: user.id,
          nom: user.nom,
          email: user.email,
          prenom: user.prenom,
        }
      });
    }

    // Vérifier si c'est une entreprise
    const [entreprise] = await connection.query(
      "SELECT * FROM entreprises WHERE email = ?",
      [email]
    );

    if (entreprise.length > 0) {
      const user = entreprise[0];
      const correct = await bcrypt.compare(mot_de_passe, user.mot_de_passe);

      if (!correct) {
        return res.status(401).json({ error: "Mot de passe incorrect" });
      }

      return res.status(200).json({
        message: "Connexion réussie",
        role: "entreprise",      // ⚡ idem
        user: {
          id: user.id,
          nom: user.nom,
          email: user.email,
          adresse: user.adresse,
        }
      });
    }

    res.status(404).json({ error: "Utilisateur introuvable" });

  } catch (err) {
    console.error("Erreur connexion :", err);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

module.exports = { Connexion };
