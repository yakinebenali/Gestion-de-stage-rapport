const connection = require('./../BD/db'); 

// POST : Ajouter candidature
const Postuler = async (req, res) => {
    const { student_name, offer_id, message } = req.body;
    const cvPath = req.file ? `/uploads/${req.file.filename}` : null;

    if (!student_name || !offer_id) {
        return res.status(400).json({ error: 'Nom étudiant et ID offre requis' });
    }

    try {
        // 1️⃣ Vérifier que l'offre existe et récupérer entreprise_id
        const [offer] = await connection.query(
            "SELECT entreprise_id FROM offres WHERE id = ?",
            [offer_id]
        );

        if (offer.length === 0) {
            return res.status(404).json({ error: "Offre introuvable" });
        }

        const entrepriseId = offer[0].entreprise_id;

        // 2️⃣ Insérer la candidature
        const query = `
            INSERT INTO Candidature 
            (student_name, offer_id, message, cv_path, entreprise_id) 
            VALUES (?, ?, ?, ?, ?)
        `;

        const [result] = await connection.query(query, [
            student_name,
            offer_id,
            message,
            cvPath,
            entrepriseId
        ]);

        res.status(201).json({
            message: "Candidature envoyée avec succès",
            candidature: {
                id: result.insertId,
                student_name,
                offer_id,
                message,
                cv_path: cvPath,
                entreprise_id: entrepriseId
            }
        });

    } catch (err) {
        console.error("Erreur DB:", err);
        res.status(500).json({ error: "Erreur DB" });
    }
};

// GET : Récupérer toutes les candidatures
const getAllCandidatures = async (req, res) => {
  try {
    const entrepriseId = req.query.entreprise_id;

    if (!entrepriseId) {
      return res.status(400).json({ error: "entreprise_id manquant" });
    }

    const [results] = await connection.query(
      `SELECT * FROM Candidature WHERE entreprise_id = ? ORDER BY id DESC`,
      [entrepriseId]
    );

    res.json(results);

  } catch (err) {
    console.error("Erreur DB:", err);
    res.status(500).json({ error: "Erreur DB" });
  }
};


// PUT : Mettre à jour le statut d'une candidature
const updateCandidatureStatus = (req, res) => {
    const id = req.params.id;
    const { status } = req.body;

    if (!status || !['acceptee', 'refusee'].includes(status)) {
        return res.status(400).json({ error: 'Statut invalide' });
    }

    const query = `UPDATE Candidature SET status = ? WHERE id = ?`;
    connection.query(query, [status, id], (err, result) => {
        if (err) {
            console.error('Erreur DB:', err);
            return res.status(500).json({ error: 'Erreur DB' });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Candidature non trouvée' });
        }

        res.json({ message: `Candidature mise à jour` });
    });
};


module.exports = { Postuler, getAllCandidatures, updateCandidatureStatus };
