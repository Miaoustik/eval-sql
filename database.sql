CREATE USER IF NOT EXISTS 'cinema'@'localhost' IDENTIFIED BY '$2y$10$CBbKEp4pb6y2D7ab1PqcFOvH0GKnrSM5jpGdmweGcuJH1MsLMVjUC';

CREATE DATABASE IF NOT EXISTS cinemadb 
CHARACTER SET = 'utf8mb4'
COLLATE = 'utf8mb4_general_ci';

GRANT ALL PRIVILEGES ON cinemadb.* TO 'cinema'@'localhost';

CREATE TABLE cinemadb.cinema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    code_postal VARCHAR(10) NOT NULL,
    ville VARCHAR(50) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE cinemadb.tarif (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prix DECIMAL(5, 2) NOT NULL,
    nom VARCHAR(50)
) ENGINE = InnoDB;

CREATE TABLE cinemadb.film (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    duree INT
) ENGINE = InnoDB;

CREATE TABLE cinemadb.salle (
    id INT AUTO_INCREMENT PRIMARY KEY,
    total_place INT NOT NULL,
    cinema_id INT NOT NULL,
    FOREIGN KEY (cinema_id) REFERENCES cinema(id)
) ENGINE = InnoDB;

CREATE TABLE cinemadb.genre (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE cinemadb.user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    roles LONGTEXT NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    tarif_id INT,
    FOREIGN KEY (tarif_id) REFERENCES tarif(id)
) ENGINE = InnoDB;

CREATE TABLE cinemadb.add_seance_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    cinema_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (cinema_id) REFERENCES cinema(id)
) ENGINE = InnoDB;

CREATE TABLE cinemadb.seance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    horaire DATETIME NOT NULL,
    film_id INT NOT NULL,
    salle_id INT NOT NULL,
    place_libre INT,
    FOREIGN KEY (film_id) REFERENCES film(id),
    FOREIGN KEY (salle_id) REFERENCES salle(id)
) ENGINE = InnoDB;

CREATE TABLE cinemadb.reservation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seance_id INT NOT NULL,
    user_id INT NOT NULL,
    tarif_id INT NOT NULL,
    FOREIGN KEY (seance_id) REFERENCES seance(id),
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (tarif_id) REFERENCES tarif(id)
) ENGINE = InnoDB;

CREATE TABLE cinemadb.film_genre (
    film_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (film_id, genre_id),
    FOREIGN KEY (film_id) REFERENCES film(id),
    FOREIGN KEY (genre_id) REFERENCES genre(id)
) ENGINE = InnoDB;

DELIMITER //
CREATE TRIGGER cinemadb.add_place_libre
AFTER INSERT ON cinemadb.reservation
FOR EACH ROW
BEGIN
  UPDATE cinemadb.seance
  SET place_libre = place_libre - 1
  WHERE id = NEW.seance_id;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER cinemadb.remove_place_libre
AFTER DELETE ON cinemadb.reservation
FOR EACH ROW
BEGIN
  UPDATE cinemadb.seance
  SET place_libre = place_libre + 1
  WHERE id = OLD.seance_id;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER cinemadb.set_place_libre
BEFORE INSERT ON cinemadb.seance
FOR EACH ROW
BEGIN
  SET NEW.place_libre = (SELECT total_place FROM salle WHERE id = NEW.salle_id);
END; //
DELIMITER ;

INSERT INTO cinemadb.cinema (nom, adresse, code_postal, ville)
VALUES ('Cinéma 1', '1 rue de la paix', '75000', 'Paris'),
('Cinéma 2', '2 avenue des champs-élysées', '75001', 'Paris'),
('Cinéma 3', '3 boulevard saint-germain', '75002', 'Paris'),
('Cinéma 4', '4 boulevard saint-germain', '75002', 'Paris'),
('Cinéma 5', '5 boulevard saint-germain', '75002', 'Paris');

INSERT INTO cinemadb.tarif (prix, nom)
VALUES ('9.20', 'Plein tarif'),
('7.60', 'Étudiant'),
('5.90', 'Moins de 14 ans');

INSERT INTO cinemadb.film (nom, duree)
VALUES ('Film 1', 90),
('Film 2', 120),
('Film 3', 130),
('Film 4', 140),
('Film 5', 150);

INSERT INTO cinemadb.salle (total_place, cinema_id)
VALUES (100, 1),
(200, 1),
(150, 1),
(240, 2),
(230, 2),
(210, 2),
(140, 3),
(160, 3),
(170, 3),
(200, 3),
(250, 3);

INSERT INTO cinemadb.genre (nom)
VALUES ('Action'),
('Comédie'),
('Horreur'),
('Humour'),
('Drame');

INSERT INTO cinemadb.film_genre (film_id, genre_id)
VALUES (1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 3),
(3, 5),
(4, 4),
(5, 5);

INSERT INTO cinemadb.user (roles, email, password, tarif_id)
VALUES (JSON_ARRAY('ROLE_ADMIN'), 'admin@example.com', '$2y$10$zhA19yOeeGyP/Jr1oEKR0uGjQrk58FEgVja.AAJaneW32K3i9Hd3q', 1),
(JSON_ARRAY('ROLE_USER'), 'user@example.com', '$2y$10$zhA19yOeeGyP/Jr1oEKR0uGjQrk58FEgVja.AAJaneW32K3i9Hd3q', 2),
(JSON_ARRAY('ROLE_USER', 'ROLE_SEANCE'), 'useraddseance@example.com', '$2y$10$zhA19yOeeGyP/Jr1oEKR0uGjQrk58FEgVja.AAJaneW32K3i9Hd3q', 2),
(JSON_ARRAY('ROLE_USER', 'ROLE_SEANCE'), 'useraddseance2@example.com', '$2y$10$zhA19yOeeGyP/Jr1oEKR0uGjQrk58FEgVja.AAJaneW32K3i9Hd3q', 3),
(JSON_ARRAY('ROLE_USER', 'ROLE_SEANCE'), 'useraddseance3@example.com', '$2y$10$zhA19yOeeGyP/Jr1oEKR0uGjQrk58FEgVja.AAJaneW32K3i9Hd3q', 3),
(JSON_ARRAY('ROLE_USER', 'ROLE_SEANCE'), 'useraddseance4@example.com', '$2y$10$zhA19yOeeGyP/Jr1oEKR0uGjQrk58FEgVja.AAJaneW32K3i9Hd3q', 3),
(JSON_ARRAY('ROLE_USER', 'ROLE_SEANCE'), 'useraddseance5@example.com', '$2y$10$zhA19yOeeGyP/Jr1oEKR0uGjQrk58FEgVja.AAJaneW32K3i9Hd3q', 3);

INSERT INTO cinemadb.add_seance_user (user_id, cinema_id)
VALUES (3, 1),
(4, 2),
(5, 3),
(6, 4),
(7, 5);

INSERT INTO cinemadb.seance (horaire, film_id, salle_id)
VALUES ('2023-04-01 13:00:00', 1, 1),
('2023-04-01 15:00:00', 1, 1),
('2023-04-01 17:00:00', 1, 1),
('2023-04-01 19:00:00', 1, 1),
('2023-04-01 21:00:00', 1, 1),
('2023-04-01 20:00:00', 1, 2),
('2023-05-02 20:00:00', 2, 3),
('2023-05-02 20:00:00', 2, 3),
('2023-05-02 20:00:00', 2, 4),
('2023-05-02 20:00:00', 2, 2),
('2023-05-02 20:00:00', 2, 2),
('2023-03-03 20:00:00', 3, 3);

INSERT INTO cinemadb.reservation (seance_id, user_id, tarif_id)
VALUES (1, 1, 1),
(2, 2, 2),
(3, 3, 2),
(1, 4, 3),
(2, 5, 3);