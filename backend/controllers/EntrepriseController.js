// EntrepriseController.js
const connection = require('./../BD/db'); // Importe la connexion MySQL



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
