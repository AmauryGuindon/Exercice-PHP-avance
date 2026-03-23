-- ============================================================
-- 📦 DATASET : Plateforme E-Commerce "ShopE89"
-- ============================================================
-- Ce fichier crée la base de données, les tables et insère
-- des données réalistes pour les exercices PHP + BDD.
--
-- Pour l'utiliser :
-- 1. Ouvrez phpMyAdmin ou un terminal MySQL
-- 2. Exécutez ce fichier : mysql -u root -p < dataset.sql
-- ============================================================

DROP DATABASE IF EXISTS shop_e89;
CREATE DATABASE shop_e89 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shop_e89;

-- ============================================================
-- TABLE : categories
-- ============================================================
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id INT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- TABLE : users (clients + admins)
-- ============================================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('client', 'admin') DEFAULT 'client',
    city VARCHAR(100),
    country VARCHAR(50) DEFAULT 'France',
    birth_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

-- ============================================================
-- TABLE : products
-- ============================================================
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category_id INT,
    is_available TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- TABLE : orders (commandes)
-- ============================================================
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    shipping_address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE : order_items (lignes de commande)
-- ============================================================
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE : reviews (avis clients)
-- ============================================================
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE : tags (pour les produits, relation N:N)
-- ============================================================
CREATE TABLE tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE PIVOT : product_tag
-- ============================================================
CREATE TABLE product_tag (
    product_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (product_id, tag_id),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- INSERTION DES DONNÉES
-- ============================================================

-- ---- Catégories (avec sous-catégories) ----
INSERT INTO categories (id, name, description, parent_id) VALUES
(1, 'Informatique', 'Matériel et accessoires informatiques', NULL),
(2, 'Ordinateurs portables', 'Laptops et ultrabooks', 1),
(3, 'Composants PC', 'Cartes graphiques, RAM, SSD...', 1),
(4, 'Périphériques', 'Claviers, souris, écrans', 1),
(5, 'Smartphones', 'Téléphones mobiles', NULL),
(6, 'Audio', 'Casques, enceintes, écouteurs', NULL),
(7, 'Gaming', 'Matériel et accessoires gaming', NULL),
(8, 'Consoles', 'Consoles de jeux vidéo', 7),
(9, 'Accessoires gaming', 'Manettes, casques gaming', 7),
(10, 'Photo & Vidéo', 'Appareils photo, caméras', NULL);

-- ---- Utilisateurs ----
-- Mots de passe hachés avec password_hash('password123', PASSWORD_DEFAULT)
-- En vrai, chaque mot de passe serait différent. Ici c'est pour le dataset.
INSERT INTO users (id, first_name, last_name, email, password, role, city, country, birth_date, created_at, is_active) VALUES
(1,  'Alice',    'Martin',    'alice.martin@email.com',    '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'admin',  'Paris',      'France',   '1990-03-15', '2024-01-10 09:00:00', 1),
(2,  'Bob',      'Dupont',    'bob.dupont@email.com',      '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Lyon',       'France',   '1995-07-22', '2024-01-15 14:30:00', 1),
(3,  'Charlie',  'Durand',    'charlie.durand@email.com',  '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Marseille',  'France',   '1988-11-03', '2024-02-01 10:00:00', 1),
(4,  'Diana',    'Leroy',     'diana.leroy@email.com',     '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Toulouse',   'France',   '1992-05-18', '2024-02-14 16:45:00', 1),
(5,  'Eve',      'Moreau',    'eve.moreau@email.com',      '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Bordeaux',   'France',   '2000-01-30', '2024-03-01 08:15:00', 1),
(6,  'Frank',    'Simon',     'frank.simon@email.com',     '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Nantes',     'France',   '1985-09-12', '2024-03-10 11:00:00', 1),
(7,  'Grace',    'Laurent',   'grace.laurent@email.com',   '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Strasbourg', 'France',   '1998-04-25', '2024-03-20 13:30:00', 1),
(8,  'Hugo',     'Michel',    'hugo.michel@email.com',     '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Lille',      'France',   '1993-12-08', '2024-04-05 09:45:00', 1),
(9,  'Isabelle', 'Garcia',    'isabelle.garcia@email.com', '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Bruxelles',  'Belgique', '1991-06-14', '2024-04-15 17:00:00', 1),
(10, 'Jules',    'Petit',     'jules.petit@email.com',     '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Genève',     'Suisse',   '1997-08-20', '2024-05-01 10:30:00', 1),
(11, 'Karim',    'Benali',    'karim.benali@email.com',    '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Paris',      'France',   '1994-02-28', '2024-05-10 14:00:00', 1),
(12, 'Laura',    'Fontaine',  'laura.fontaine@email.com',  '$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', 'client', 'Lyon',       'France',   '1999-10-05', '2024-06-01 08:00:00', 0);

-- ---- Produits ----
INSERT INTO products (id, name, description, price, stock, category_id, is_available, created_at) VALUES
(1,  'MacBook Pro 14"',           'Apple M3 Pro, 18Go RAM, 512Go SSD',                1999.99, 25,  2,  1, '2024-01-15 10:00:00'),
(2,  'ThinkPad X1 Carbon',        'Intel i7, 16Go RAM, 512Go SSD',                    1549.00, 30,  2,  1, '2024-01-20 10:00:00'),
(3,  'Dell XPS 15',               'Intel i9, 32Go RAM, 1To SSD',                      2199.00, 12,  2,  1, '2024-02-01 10:00:00'),
(4,  'RTX 4070 Ti',               'NVIDIA GeForce RTX 4070 Ti 12Go',                   649.99, 40,  3,  1, '2024-02-10 10:00:00'),
(5,  'RTX 4090',                  'NVIDIA GeForce RTX 4090 24Go',                     1599.99,  8,  3,  1, '2024-02-15 10:00:00'),
(6,  'Samsung 990 Pro 2To',       'SSD NVMe M.2, lecture 7450 Mo/s',                   159.99, 100, 3,  1, '2024-03-01 10:00:00'),
(7,  'Corsair Vengeance 32Go',    'DDR5 6000MHz, 2x16Go',                              119.99, 75,  3,  1, '2024-03-05 10:00:00'),
(8,  'Logitech MX Master 3S',     'Souris sans fil ergonomique',                        89.99, 60,  4,  1, '2024-03-10 10:00:00'),
(9,  'Keychron Q1 Pro',           'Clavier mécanique 75%, switches Gateron',           179.99, 35,  4,  1, '2024-03-15 10:00:00'),
(10, 'LG UltraGear 27" 4K',      'Moniteur gaming 144Hz, HDR600',                     549.99, 20,  4,  1, '2024-03-20 10:00:00'),
(11, 'iPhone 15 Pro',             'Apple A17 Pro, 256Go',                              1199.00, 50,  5,  1, '2024-01-10 10:00:00'),
(12, 'Samsung Galaxy S24 Ultra',  'Snapdragon 8 Gen 3, 256Go',                        1169.00, 45,  5,  1, '2024-02-01 10:00:00'),
(13, 'Google Pixel 8 Pro',        'Tensor G3, 128Go',                                  899.00, 30,  5,  1, '2024-02-15 10:00:00'),
(14, 'Sony WH-1000XM5',          'Casque sans fil, réduction de bruit',                349.99, 55,  6,  1, '2024-01-20 10:00:00'),
(15, 'AirPods Pro 2',            'Apple, réduction de bruit adaptative',               279.99, 80,  6,  1, '2024-02-01 10:00:00'),
(16, 'JBL Charge 5',             'Enceinte Bluetooth portable, IP67',                  149.99, 65,  6,  1, '2024-03-01 10:00:00'),
(17, 'PlayStation 5',             'Console Sony, lecteur Blu-ray',                      499.99, 15,  8,  1, '2024-01-05 10:00:00'),
(18, 'Nintendo Switch OLED',     'Console hybride, écran OLED 7"',                     349.99, 40,  8,  1, '2024-01-10 10:00:00'),
(19, 'Xbox Series X',            'Console Microsoft, 1To SSD',                         499.99, 20,  8,  1, '2024-01-15 10:00:00'),
(20, 'Manette PS5 DualSense',    'Manette sans fil, retour haptique',                   69.99, 90,  9,  1, '2024-02-01 10:00:00'),
(21, 'Canon EOS R6 Mark II',     'Hybride plein format, 24.2MP',                      2499.00,  10, 10, 1, '2024-03-01 10:00:00'),
(22, 'GoPro Hero 12',            'Caméra action, 5.3K, stabilisation',                 399.99, 25,  10, 1, '2024-03-15 10:00:00'),
(23, 'Produit retiré',           'Ce produit n est plus disponible',                    99.99,  0,   3,  0, '2024-01-01 10:00:00'),
(24, 'Razer DeathAdder V3',      'Souris gaming, capteur 30K DPI',                      79.99, 50,  9,  1, '2024-04-01 10:00:00'),
(25, 'Asus ROG Strix G16',       'Intel i7, RTX 4060, 16Go RAM',                     1399.00, 18,  2,  1, '2024-04-10 10:00:00');

-- ---- Tags ----
INSERT INTO tags (id, name) VALUES
(1, 'promo'),
(2, 'nouveauté'),
(3, 'best-seller'),
(4, 'premium'),
(5, 'eco-friendly'),
(6, 'reconditionné'),
(7, 'exclusivité web');

-- ---- Product-Tag (relation N:N) ----
INSERT INTO product_tag (product_id, tag_id) VALUES
(1, 4), (1, 3),
(2, 3),
(3, 4), (3, 2),
(4, 3), (4, 1),
(5, 4),
(6, 1), (6, 3),
(8, 3), (8, 5),
(9, 2), (9, 7),
(11, 3), (11, 4),
(12, 2), (12, 4),
(13, 5),
(14, 3), (14, 1),
(15, 3),
(17, 3),
(18, 3), (18, 1),
(21, 4), (21, 2),
(22, 2),
(24, 2), (24, 7),
(25, 2);

-- ---- Commandes ----
INSERT INTO orders (id, user_id, status, total_amount, shipping_address, created_at) VALUES
-- Bob : 3 commandes
(1,  2,  'delivered',  2089.98, '12 rue de la Paix, 69001 Lyon',          '2024-02-20 10:00:00'),
(2,  2,  'delivered',   89.99,  '12 rue de la Paix, 69001 Lyon',          '2024-04-15 14:00:00'),
(3,  2,  'pending',    1599.99, '12 rue de la Paix, 69001 Lyon',          '2024-06-01 09:00:00'),
-- Charlie : 2 commandes
(4,  3,  'delivered',  1199.00, '5 bd Longchamp, 13001 Marseille',        '2024-03-05 11:00:00'),
(5,  3,  'shipped',    629.98,  '5 bd Longchamp, 13001 Marseille',        '2024-05-20 16:00:00'),
-- Diana : 2 commandes
(6,  4,  'delivered',  2279.98, '8 allée Jean Jaurès, 31000 Toulouse',    '2024-03-15 09:30:00'),
(7,  4,  'cancelled',  499.99,  '8 allée Jean Jaurès, 31000 Toulouse',    '2024-04-01 10:00:00'),
-- Eve : 1 commande
(8,  5,  'confirmed',  349.99,  '22 cours de l Intendance, 33000 Bordeaux','2024-05-10 13:00:00'),
-- Frank : 3 commandes
(9,  6,  'delivered',  1549.00, '3 rue Crébillon, 44000 Nantes',          '2024-02-28 08:00:00'),
(10, 6,  'delivered',   349.99, '3 rue Crébillon, 44000 Nantes',          '2024-04-20 15:00:00'),
(11, 6,  'shipped',    719.98,  '3 rue Crébillon, 44000 Nantes',          '2024-06-05 10:30:00'),
-- Grace : 1 commande
(12, 7,  'delivered',  1999.99, '15 place Kléber, 67000 Strasbourg',      '2024-04-10 12:00:00'),
-- Hugo : 2 commandes
(13, 8,  'delivered',   499.99, '7 rue Faidherbe, 59000 Lille',           '2024-03-25 14:00:00'),
(14, 8,  'pending',    2499.00, '7 rue Faidherbe, 59000 Lille',           '2024-06-10 09:00:00'),
-- Isabelle : 2 commandes
(15, 9,  'delivered',  1169.00, '10 Grand Place, 1000 Bruxelles',         '2024-04-05 11:30:00'),
(16, 9,  'delivered',   229.98, '10 Grand Place, 1000 Bruxelles',         '2024-05-15 16:45:00'),
-- Jules : 1 commande
(17, 10, 'confirmed',  899.00,  '4 rue du Rhône, 1204 Genève',           '2024-05-25 10:00:00'),
-- Karim : 2 commandes
(18, 11, 'delivered',  2199.00, '25 avenue des Champs-Élysées, 75008 Paris','2024-03-01 09:00:00'),
(19, 11, 'shipped',    279.99,  '25 avenue des Champs-Élysées, 75008 Paris','2024-06-08 14:00:00');

-- ---- Lignes de commande (order_items) ----
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
-- Commande 1 (Bob) : MacBook + souris
(1, 1,  1, 1999.99),
(1, 8,  1,   89.99),
-- Commande 2 (Bob) : souris seule
(2, 8,  1,   89.99),
-- Commande 3 (Bob) : RTX 4090
(3, 5,  1, 1599.99),
-- Commande 4 (Charlie) : iPhone 15 Pro
(4, 11, 1, 1199.00),
-- Commande 5 (Charlie) : AirPods + JBL
(5, 15, 1,  279.99),
(5, 16, 1,  149.99),
-- Commande 6 (Diana) : MacBook + AirPods
(6, 1,  1, 1999.99),
(6, 15, 1,  279.99),
-- Commande 7 (Diana, annulée) : PS5
(7, 17, 1,  499.99),
-- Commande 8 (Eve) : Sony casque
(8, 14, 1,  349.99),
-- Commande 9 (Frank) : ThinkPad
(9, 2,  1, 1549.00),
-- Commande 10 (Frank) : Nintendo Switch
(10, 18, 1, 349.99),
-- Commande 11 (Frank) : RTX 4070 Ti + manette PS5
(11, 4,  1, 649.99),
(11, 20, 1,  69.99),
-- Commande 12 (Grace) : MacBook Pro
(12, 1,  1, 1999.99),
-- Commande 13 (Hugo) : PS5
(13, 17, 1, 499.99),
-- Commande 14 (Hugo) : Canon EOS
(14, 21, 1, 2499.00),
-- Commande 15 (Isabelle) : Samsung Galaxy
(15, 12, 1, 1169.00),
-- Commande 16 (Isabelle) : manette PS5 x2 + Razer
(16, 20, 2,  69.99),
(16, 24, 1,  79.99),
-- Commande 17 (Jules) : Pixel 8 Pro
(17, 13, 1, 899.00),
-- Commande 18 (Karim) : Dell XPS
(18, 3,  1, 2199.00),
-- Commande 19 (Karim) : AirPods Pro
(19, 15, 1, 279.99);

-- ---- Avis clients ----
INSERT INTO reviews (user_id, product_id, rating, comment, created_at) VALUES
-- MacBook Pro 14"
(2,  1, 5, 'Excellent laptop, rapide et silencieux. L écran est magnifique.',           '2024-03-10 10:00:00'),
(4,  1, 4, 'Très bon mais le prix est élevé. Le clavier est top.',                      '2024-04-20 14:00:00'),
(7,  1, 5, 'Parfait pour le développement. Je recommande.',                              '2024-05-15 09:00:00'),
-- ThinkPad X1 Carbon
(6,  2, 4, 'Solide et fiable. Le clavier est le meilleur du marché.',                   '2024-04-01 11:00:00'),
-- Dell XPS 15
(11, 3, 5, 'Machine de guerre. Parfait pour le montage vidéo.',                          '2024-04-10 16:00:00'),
-- RTX 4070 Ti
(6,  4, 4, 'Excellent rapport qualité/prix pour du 1440p.',                              '2024-06-10 10:00:00'),
-- iPhone 15 Pro
(3,  11, 4, 'Très bon téléphone, l appareil photo est incroyable.',                     '2024-04-15 13:00:00'),
(11, 11, 3, 'Bon téléphone mais pas de grande évolution par rapport au 14 Pro.',        '2024-05-20 10:00:00'),
-- Samsung Galaxy S24 Ultra
(9,  12, 5, 'Le meilleur smartphone Android. L IA est bluffante.',                      '2024-05-01 15:00:00'),
-- Pixel 8 Pro
(10, 13, 4, 'Photos exceptionnelles. L intégration Google est parfaite.',               '2024-06-05 11:00:00'),
-- Sony WH-1000XM5
(5,  14, 5, 'La réduction de bruit est incroyable. Très confortable.',                  '2024-06-01 09:00:00'),
-- AirPods Pro 2
(3,  15, 4, 'Très bonne qualité sonore. L audio spatial est top.',                      '2024-06-10 14:00:00'),
(4,  15, 5, 'Indispensable avec un iPhone. Réduction de bruit au top.',                 '2024-04-25 10:00:00'),
-- JBL Charge 5
(5,  16, 3, 'Bon son mais un peu lourd pour le transport.',                              '2024-06-15 16:00:00'),
-- PS5
(8,  17, 5, 'La meilleure console de cette génération.',                                 '2024-04-20 18:00:00'),
-- Nintendo Switch OLED
(6,  18, 4, 'Parfait pour jouer en famille. L écran OLED est superbe.',                 '2024-05-10 12:00:00'),
-- Manette PS5
(8,  20, 5, 'Le retour haptique change tout. Meilleure manette du marché.',             '2024-05-01 10:00:00'),
(9,  20, 4, 'Très bonne manette, mais l autonomie pourrait être meilleure.',            '2024-06-01 14:00:00'),
-- Canon EOS R6 Mark II
(8,  21, 4, 'Superbe appareil. L autofocus est impressionnant.',                         '2024-06-15 09:00:00'),
-- Razer DeathAdder V3
(9,  24, 5, 'Légère et précise. Parfaite pour le FPS.',                                  '2024-06-10 11:00:00'),
-- Logitech MX Master 3S
(2,  8,  5, 'La meilleure souris pour travailler. Ergonomie parfaite.',                  '2024-05-01 10:00:00'),
-- Keychron Q1 Pro
(7,  9,  4, 'Clavier solide et agréable. Le son des switches est satisfaisant.',         '2024-06-01 15:00:00');

-- ============================================================
-- VUES UTILES (bonus pour les exercices avancés)
-- ============================================================

-- Vue : résumé des commandes avec nom du client
CREATE VIEW v_orders_summary AS
SELECT
    o.id AS order_id,
    CONCAT(u.first_name, ' ', u.last_name) AS client,
    o.status,
    o.total_amount,
    o.created_at AS order_date,
    COUNT(oi.id) AS nb_items
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, u.first_name, u.last_name, o.status, o.total_amount, o.created_at;
