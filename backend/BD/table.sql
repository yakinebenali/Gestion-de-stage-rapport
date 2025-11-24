CREATE TABLE Rapport (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    description TEXT
);
ALTER TABLE Rapport ADD COLUMN pdf_path VARCHAR(255);

CREATE TABLE entreprises (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  mot_de_passe VARCHAR(255) NOT NULL,
  adresse VARCHAR(255),
  telephone VARCHAR(20),
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE offres (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titre VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  duree VARCHAR(50),
  competences VARCHAR(255),
  date_publication TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  entreprise_id INT NOT NULL,
  FOREIGN KEY (entreprise_id) REFERENCES entreprises(id) ON DELETE CASCADE
);


CREATE TABLE Candidature (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(255) NOT NULL,
    offer_id VARCHAR(255) NOT NULL,
    message TEXT,
    cv_path VARCHAR(255)
);