// db.js
const mysql = require('mysql2');
require('dotenv').config();

// Création d'un pool (meilleure pratique)
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'GestionRappStag_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Export du pool avec support des promesses
const db = pool.promise();

console.log('Connexion MySQL configurée (pool)');

module.exports = db;