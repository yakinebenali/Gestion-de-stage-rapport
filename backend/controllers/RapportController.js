// RapportController.js
const connection = require('./../BD/db'); // Importe la connexion MySQL
const AjoutRapport = (req, res) => {
    const { title, company, start_date, end_date, description } = req.body;
    const pdfPath = req.file ? `/uploads/${req.file.filename}` : null;

    // Validation des champs obligatoires
    if (!title || !company) {
        return res.status(400).json({ error: 'Le titre et l\'entreprise sont requis' });
    }

    // Requête SQL pour insérer un rapport
    const query = 'INSERT INTO Rapport (title, company, start_date, end_date, description, pdf_path) VALUES (?, ?, ?, ?, ?, ?)';
    connection.query(query, [title, company, start_date, end_date, description, pdfPath], (err, result) => {
        if (err) {
            console.error('Erreur lors de l\'ajout du rapport:', err);
            return res.status(500).json({ error: 'Erreur serveur lors de l\'ajout du rapport' });
        }
        res.status(201).json({
            message: 'Rapport ajouté avec succès',
            rapport: { id: result.insertId, title, company, start_date, end_date, description, pdf_path: pdfPath }
        });
    });
};
const getAllRapports = (req, res) => {
    const query = 'SELECT * FROM Rapport';
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Erreur lors de la récupération des rapports:', err);
            return res.status(500).json({ error: 'Erreur serveur lors de la récupération des rapports' });
        }
        res.status(200).json(results);
    });
};

module.exports = { AjoutRapport, getAllRapports };