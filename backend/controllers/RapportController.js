// RapportController.js
const connection = require('./../BD/db'); // Importe la connexion MySQL
const AjoutRapport = (req, res) => {
    const { title, company, start_date, end_date, description, filiere } = req.body;
    const pdfPath = req.file ? `/uploads/${req.file.filename}` : null;

    // Validation des champs obligatoires
    if (!title || !company || !filiere) {
        return res.status(400).json({ error: 'Titre, entreprise et filière sont requis' });
    }

    // Requête SQL pour insérer un rapport
    const query = `
        INSERT INTO Rapport (title, company, start_date, end_date, description, pdf_path, filiere)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    connection.query(
        query,
        [title, company, start_date, end_date, description, pdfPath, filiere],
        (err, result) => {
            if (err) {
                console.error('Erreur lors de l\'ajout du rapport:', err);
                return res.status(500).json({ error: 'Erreur serveur lors de l\'ajout du rapport' });
            }

            res.status(201).json({
                message: 'Rapport ajouté avec succès',
                rapport: {
                    id: result.insertId,
                    title,
                    company,
                    start_date,
                    end_date,
                    description,
                    pdf_path: pdfPath,
                    filiere
                }
            });
        }
    );
};

const getAllRapports = async (req, res) => {
    try {
        const [results] = await connection.query('SELECT * FROM Rapport');
        res.status(200).json(results);
    } catch (err) {
        console.error('Erreur lors de la récupération des rapports:', err);
        res.status(500).json({ error: 'Erreur serveur lors de la récupération des rapports' });
    }
};

const deleteRapport = async (req, res) => {
  const rapportId = req.params.id;

  if (!rapportId) {
    return res.status(400).json({ error: "ID du rapport manquant" });
  }

  try {
    const [result] = await connection.query(
      "DELETE FROM Rapport WHERE id = ?", // ⚠️ Corrigé ici
      [rapportId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Rapport non trouvé" });
    }

    res.status(200).json({ message: "Rapport supprimé avec succès" });
  } catch (err) {
    console.error("Erreur suppression rapport :", err);
    res.status(500).json({ error: "Erreur serveur" });
  }
};
// updateRapport
const updateRapport = async (req, res) => {
    const id = req.params.id;
    const { title, company, start_date, end_date, description, filiere } = req.body;

    try {
        // 📌 Récupérer l'ancien rapport (table Rapport)
        const [oldData] = await connection.query(
            "SELECT pdf_path FROM Rapport WHERE id = ?",
            [id]
        );

        if (oldData.length === 0) {
            return res.status(404).json({ error: "Rapport introuvable" });
        }

        let pdfPath = oldData[0].pdf_path;

        // 📌 Si un fichier PDF est envoyé → remplacer
        if (req.file) {
            pdfPath = "/uploads/" + req.file.filename;
        }

        // 📌 Mise à jour dans la bonne table : Rapport
        await connection.query(
            `UPDATE Rapport 
             SET title = ?, company = ?, start_date = ?, end_date = ?, description = ?, filiere = ?, pdf_path = ?
             WHERE id = ?`,
            [title, company, start_date, end_date, description, filiere, pdfPath, id]
        );

        res.json({ message: "Rapport mis à jour avec succès" });

    } catch (err) {
        console.error("Erreur update :", err);
        res.status(500).json({ error: "Erreur serveur" });
    }
};



module.exports = { AjoutRapport, getAllRapports, deleteRapport, updateRapport };
