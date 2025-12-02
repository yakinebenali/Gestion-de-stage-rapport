const connection = require('./../BD/db'); 

// POST : Ajouter candidature
const Postuler = (req, res) => {
    const { student_name, offer_id, message } = req.body;
    const cvPath = req.file ? `/uploads/${req.file.filename}` : null;

    if (!student_name || !offer_id) {
        return res.status(400).json({ error: 'Nom étudiant et ID offre requis' });
    }

    const query = `
        INSERT INTO Candidature (student_name, offer_id, message, cv_path)
        VALUES (?, ?, ?, ?)
    `;

    connection.query(query, [student_name, offer_id, message, cvPath], (err, result) => {
        if (err) {
            console.error('Erreur DB:', err);
            return res.status(500).json({ error: 'Erreur DB' });
        }

        res.status(201).json({
            message: 'Candidature envoyée avec succès',
            candidature: {
                id: result.insertId,
                student_name,
                offer_id,
                message,
                cv_path: cvPath
            }
        });
    });
};

// GET : Récupérer toutes les candidatures
const getAllCandidatures = async (req, res) => {
  try {
    const [results] = await connection.query(`
      SELECT * FROM Candidature ORDER BY id DESC
    `);

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

    if (!status || !['accepter', 'refuser'].includes(status)) {
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

        res.json({ message: `Candidature ${status}` });
    });
};

module.exports = { Postuler, getAllCandidatures, updateCandidatureStatus };
