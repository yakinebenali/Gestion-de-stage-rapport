// OffreController.js
const connection = require('./../BD/db'); // Importe la connexion MySQL

// Fonction pour ajouter une offre
const AjoutOffre = (req, res) => {
    const entreprise_id = req.query.entreprise_id;   // récupération automatique
    const { titre, description, duree, competences } = req.body;

    if (!titre || !description || !entreprise_id) {
        return res.status(400).json({ error: "titre, description et entreprise_id requis" });
    }

    const query = `
        INSERT INTO offres (titre, description, duree, competences, entreprise_id)
        VALUES (?, ?, ?, ?, ?)
    `;

    connection.query(query, [titre, description, duree, competences, entreprise_id], (err, result) => {
        if (err) {
            console.error("Erreur ajout offre:", err);
            return res.status(500).json({ error: "Erreur serveur" });
        }

        res.status(201).json({
            message: "Offre ajoutée avec succès",
            offre: {
                id: result.insertId,
                titre,
                description,
                duree,
                competences,
                entreprise_id
            }
        });
    });
};

// Fonction pour récupérer toutes les offres
const getAllOffres = async (req, res) => {
  try {
    const entrepriseId = req.query.entreprise_id;

    let query = "SELECT * FROM offres";
    let params = [];

    if (entrepriseId) {
      query = "SELECT * FROM offres WHERE entreprise_id = ?";
      params = [entrepriseId];
    }

    const [results] = await connection.query(query, params);
    res.status(200).json(results);

  } catch (err) {
    console.error("Erreur lors de la récupération des offres:", err);
    res.status(500).json({ error: "Erreur serveur lors de la récupération des offres" });
  }
};

// Fonction pour modifier une offre
// Modifier une offre
const ModifierOffre = (req, res) => {
    console.log("➡️ Requête reçue pour ModifierOffre");

    const offre_id = req.params.id;
    const { titre, description, duree, competences } = req.body;

    // Validation de base pour s'assurer que les données minimales sont là
    if (!titre || !description) {
        console.log("⚠️ Validation échouée : titre ou description manquante.");
        return res.status(400).json({ error: "Le titre et la description sont requis." });
    }

    console.log("➡️ Données reçues :", { titre, description, duree, competences, offre_id });

    // La requête SQL est correctement écrite pour un UPDATE
    const query = `
        UPDATE offres
        SET titre = ?, description = ?, duree = ?, competences = ?
        WHERE id = ?
    `;

    connection.query(
        query,
        [titre, description, duree, competences, offre_id],
        (err, result) => {
            console.log("➡️ Résultat SQL reçu ou erreur");

            if (err) {
                console.error("⚠️ Erreur SQL:", err);
                // Retourne l'erreur 500 et termine la requête
                return res.status(500).json({ error: "Erreur serveur SQL" });
            }

            if (result.affectedRows === 0) {
                console.log("➡️ Offre non trouvée");
                // Retourne l'erreur 404 et termine la requête
                return res.status(404).json({ error: "Offre non trouvée" });
            }

            console.log("✅ Requête exécutée avec succès ! Envoi de la réponse 200.");
            // Retourne le succès 200 et termine la requête
            return res.status(200).json({ message: "Offre modifiée avec succès" });
        }
    );
};




// Fonction pour supprimer une offre
const SupprimerOffre = (req, res) => {
    const offre_id = req.params.id;

    const query = `DELETE FROM offres WHERE id = ?`;

    connection.query(query, [offre_id], (err, result) => {
        if (err) {
            console.error("Erreur suppression offre:", err);
            return res.status(500).json({ error: "Erreur serveur" });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: "Offre non trouvée" });
        }

        res.status(200).json({ message: "Offre supprimée avec succès" });
    });
};

module.exports = { AjoutOffre, getAllOffres, ModifierOffre,SupprimerOffre };
