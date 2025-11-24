// index.js
const express = require('express');
const http = require('http');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const app = express();
const port = 3000;
const { AjoutRapport, getAllRapports } = require('./controllers/RapportController');
const{ AjoutOffre,getAllOffres } = require('./controllers/OffreController');
const { AjoutEntreprise } = require('./controllers/EntrepriseController');
const { Postuler, getAllCandidatures } = require('./controllers/PostulerController');
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configuration de multer pour stocker les fichiers PDF
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'Uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
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

// Middleware pour gérer les erreurs de Multer
app.use((err, req, res, next) => {
    if (err instanceof multer.MulterError) {
        return res.status(400).json({ error: 'Erreur lors du traitement du fichier: ' + err.message });
    } else if (err) {
        return res.status(400).json({ error: err.message });
    }
    next();
});
// UPLOAD CV ()
// ---------------------------
const cvStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'Uploads/cv/');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const uploadCV = multer({
    storage: cvStorage,
    fileFilter: (req, file, cb) => {
        if (file.mimetype === 'application/pdf') {
            cb(null, true);
        } else {
            cb(new Error('Seuls les CV PDF sont acceptés'), false);
        }
    }
});


// Routes
app.post('/AjoutRapport', upload.single('pdf'), AjoutRapport);
app.get('/Rapports', getAllRapports); // New endpoint for fetching reports
app.use('/uploads', express.static('Uploads'));
app.post('/ajouteroffre', AjoutOffre);
app.post('/AjoutEntreprise',AjoutEntreprise);
app.get('/getAllOffres',getAllOffres);
app.post('/Postuler', uploadCV.single('cv'), Postuler);
app.get('/Candidatures', getAllCandidatures);

http.createServer(app).listen(port, '0.0.0.0', () => {
    console.log(`Serveur HTTP démarré sur le port ${port}`);
});



