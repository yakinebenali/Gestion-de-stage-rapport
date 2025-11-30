const connection = require('./../BD/db');
const bcrypt = require("bcryptjs");

// ------------------------------------------------------------
// INSCRIPTION (Étudiant ou Entreprise)
// ------------------------------------------------------------
const inscription = async (req, res) => {
  try {
    const { role, nom, email, mot_de_passe, telephone } = req.body;

    if (!role || !nom || !email || !mot_de_passe) {
      return res.status(400).json({ error: "Champs obligatoires manquants" });
    }

    // ------------- HASHAGE DU MOT DE PASSE ------------------
    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);

    // ----------------------------------------
    // 1️⃣ Inscription Étudiant
    // ----------------------------------------
    if (role === "etudiant") {
      const { prenom, niveau, specialite } = req.body;

      const sql = `
        INSERT INTO etudiants (nom, prenom, email, mot_de_passe, niveau, specialite, telephone)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `;

      const values = [
        nom,
        prenom || null,
        email,
        hashedPassword, // mot de passe sécurisé
        niveau || null,
        specialite || null,
        telephone || null
      ];

      const [result] = await connection.query(sql, values);

      return res.status(201).json({
        message: "Étudiant inscrit avec succès",
        id: result.insertId
      });
    }

    // ----------------------------------------
    // 2️⃣ Inscription Entreprise
    // ----------------------------------------
    if (role === "entreprise") {
      const { adresse } = req.body;

      const sql = `
        INSERT INTO entreprises (nom, email, mot_de_passe, adresse, telephone)
        VALUES (?, ?, ?, ?, ?)
      `;

      const values = [
        nom,
        email,
        hashedPassword, // mot de passe sécurisé
        adresse || null,
        telephone || null
      ];

      const [result] = await connection.query(sql, values);

      return res.status(201).json({
        message: "Entreprise inscrite avec succès",
        id: result.insertId
      });
    }

    return res.status(400).json({ error: "Role invalide" });

  } catch (err) {
    console.error("Erreur lors de l'inscription :", err);
    res.status(500).json({ error: "Erreur serveur lors de l'inscription" });
  }
};
module.exports = { inscription };
