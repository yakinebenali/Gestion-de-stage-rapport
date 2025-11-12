// EntrepriseController.js
const connection = require('./../BD/db'); // Importe la connexion MySQL

// Fonction pour ajouter une entreprise
const AjoutEntreprise = (req, res) => {
    const { nom, email, mot_de_passe, adresse, telephone } = req.body;

    // Validation des champs obligatoires
    if (!nom || !email || !mot_de_passe) {
        return res.status(400).json({ error: 'Le nom, l\'email et le mot de passe sont requis' });
    }

    const query = 'INSERT INTO entreprises (nom, email, mot_de_passe, adresse, telephone) VALUES (?, ?, ?, ?, ?)';
    connection.query(query, [nom, email, mot_de_passe, adresse, telephone], (err, result) => {
        if (err) {
            console.error('Erreur lors de l\'ajout de l\'entreprise:', err);
            return res.status(500).json({ error: 'Erreur serveur lors de l\'ajout de l\'entreprise' });
        }
        res.status(201).json({
            message: 'Entreprise ajoutée avec succès',
            entreprise: { id: result.insertId, nom, email, adresse, telephone }
        });
    });
};

// Fonction pour récupérer toutes les entreprises
const getAllEntreprises = (req, res) => {
    const query = 'SELECT * FROM entreprises';
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Erreur lors de la récupération des entreprises:', err);
            return res.status(500).json({ error: 'Erreur serveur lors de la récupération des entreprises' });
        }
        res.status(200).json(results);
    });
};

module.exports = { AjoutEntreprise, getAllEntreprises };
