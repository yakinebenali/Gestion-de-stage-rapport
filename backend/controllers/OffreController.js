// OffreController.js
const connection = require('./../BD/db'); // Importe la connexion MySQL

// Fonction pour ajouter une offre
const AjoutOffre = (req, res) => {
    const { titre, description, duree, competences, entreprise_id } = req.body;

    // Validation des champs obligatoires
    if (!titre || !description || !entreprise_id) {
        return res.status(400).json({ error: 'Le titre, la description et l\'ID de l\'entreprise sont requis' });
    }

    const query = 'INSERT INTO offres (titre, description, duree, competences, entreprise_id) VALUES (?, ?, ?, ?, ?)';
    connection.query(query, [titre, description, duree, competences, entreprise_id], (err, result) => {
        if (err) {
            console.error('Erreur lors de l\'ajout de l\'offre:', err);
            return res.status(500).json({ error: 'Erreur serveur lors de l\'ajout de l\'offre' });
        }
        res.status(201).json({
            message: 'Offre ajoutée avec succès',
            offre: { id: result.insertId, titre, description, duree, competences, entreprise_id }
        });
    });
};

// Fonction pour récupérer toutes les offres
const getAllOffres = async (req, res) => {
  try {
    const [results] = await connection.query('SELECT * FROM offres');
    res.status(200).json(results);
  } catch (err) {
    console.error('Erreur lors de la récupération des offres:', err);
    res.status(500).json({ error: 'Erreur serveur lors de la récupération des offres' });
  }
};


module.exports = { AjoutOffre, getAllOffres };
