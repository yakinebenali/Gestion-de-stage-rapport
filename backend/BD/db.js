// db.js
const mysql = require('mysql2');
require('dotenv').config();

const connection = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'GestionRappStag_db'
});

connection.connect((err) => {
    if (err) {
        console.error('Erreur de connexion à MySQL:', err);
        return;
    }
    console.log('Connecté à MySQL !');
});

module.exports = connection;