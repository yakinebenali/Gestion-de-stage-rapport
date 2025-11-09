// index.js
const express = require('express');
const http = require('http');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const app = express();
const port = 3000;
const { AjoutRapport } = require('./controllers/RapportController');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configuration de multer pour stocker les fichiers PDF
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); // Dossier où les fichiers seront sauvegardés
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname)); // Nom unique pour éviter les conflits
    }
});

const upload = multer({
    storage: storage,
    fileFilter: (req, file, cb) => {
        console.log('Type MIME reçu:', file.mimetype, 'Nom du fichier:', file.originalname);
        if (file.mimetype === 'application/pdf' || file.mimetype === 'application/octet-stream') {
            cb(null, true);
        } else {
            cb(new Error('Seuls les fichiers PDF sont acceptés'), false);
        }
    },
    limits: { fileSize: 5 * 1024 * 1024 } // 5 MB
});

// Route pour ajouter un rapport avec un fichier PDF
app.post('/AjoutRapport', upload.single('pdf'), AjoutRapport);

// Servir les fichiers PDF statiques
app.use('/uploads', express.static('uploads'));

http.createServer(app).listen(port, '0.0.0.0', () => {
    console.log(`Serveur HTTP démarré sur le port ${port}`);
});