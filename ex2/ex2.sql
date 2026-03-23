-- ============================================================
-- Exercice 2 : Filtres et fonctions
-- ============================================================

-- 2.1 Produit le plus cher
SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 1;

-- 2.1 Produit le moins cher
SELECT name, price
FROM products
ORDER BY price ASC
LIMIT 1;

-- 2.2 Prix moyen des produits par catégorie (nom catégorie + prix moyen arrondi à 2 décimales)
SELECT c.name AS categorie, ROUND(AVG(p.price), 2) AS prix_moyen
FROM products p
JOIN categories c ON p.category_id = c.id
GROUP BY c.id, c.name
ORDER BY prix_moyen DESC;

-- 2.3 Utilisateurs dont le prénom commence par "A" ou "E"
SELECT first_name, last_name, email
FROM users
WHERE first_name LIKE 'A%'
   OR first_name LIKE 'E%';

-- 2.4 Nombre de commandes par statut
SELECT status, COUNT(*) AS nombre_commandes
FROM orders
GROUP BY status
ORDER BY nombre_commandes DESC;

-- 2.5 Utilisateurs inscrits entre le 1er mars et le 31 mai 2024
SELECT first_name, last_name, email, created_at
FROM users
WHERE created_at BETWEEN '2024-03-01 00:00:00' AND '2024-05-31 23:59:59'
ORDER BY created_at ASC;
