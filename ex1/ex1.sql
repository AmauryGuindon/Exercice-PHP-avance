-- ============================================================
-- Exercice 1 : Premières requêtes SELECT
-- ============================================================

-- 1.1 Tous les utilisateurs (prénom, nom, email) triés par nom de famille
SELECT first_name, last_name, email
FROM users
ORDER BY last_name ASC;

-- 1.2 Produits disponibles (is_available = 1) avec prix < 200€, triés du moins cher au plus cher
SELECT name, price, is_available
FROM products
WHERE is_available = 1
  AND price < 200
ORDER BY price ASC;

-- 1.3 Nombre total de produits dans la base
SELECT COUNT(*) AS total_produits
FROM products;

-- 1.4 Utilisateurs qui habitent à Paris
SELECT first_name, last_name, email, city
FROM users
WHERE city = 'Paris';

-- 1.5 Produits créés en 2024 après le mois de mars (avril et après)
SELECT name, created_at
FROM products
WHERE created_at >= '2024-04-01'
  AND created_at < '2025-01-01';
