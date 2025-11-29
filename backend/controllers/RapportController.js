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


module.exports = { AjoutRapport, getAllRapports };