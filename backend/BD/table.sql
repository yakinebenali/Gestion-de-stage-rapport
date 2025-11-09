CREATE TABLE Rapport (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    description TEXT
);
ALTER TABLE Rapport ADD COLUMN pdf_path VARCHAR(255);