-- ============================================================
-- Exercice 5 : Requêtes avec agrégation
-- ============================================================

-- 5.1 Chiffre d'affaires total (commandes livrées uniquement)
SELECT SUM(total_amount) AS chiffre_affaires_total
FROM orders
WHERE status = 'delivered';

-- 5.2 Top 5 des produits les plus vendus par quantité totale
SELECT p.name AS produit, SUM(oi.quantity) AS quantite_totale
FROM order_items oi
JOIN products p ON oi.product_id = p.id
GROUP BY p.id, p.name
ORDER BY quantite_totale DESC
LIMIT 5;

-- 5.3 Nombre de commandes et montant total dépensé par chaque client, trié par montant décroissant
SELECT u.first_name, u.last_name,
       COUNT(o.id)          AS nombre_commandes,
       SUM(o.total_amount)  AS montant_total
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.first_name, u.last_name
ORDER BY montant_total DESC;

-- 5.4 Note moyenne des produits ayant au moins 2 avis, triés par note décroissante
SELECT p.name AS produit,
       ROUND(AVG(r.rating), 2) AS note_moyenne,
       COUNT(r.id)             AS nombre_avis
FROM products p
JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
HAVING COUNT(r.id) >= 2
ORDER BY note_moyenne DESC;

-- 5.5 Nombre de produits par catégorie, y compris les catégories sans produit (LEFT JOIN)
SELECT c.name AS categorie, COUNT(p.id) AS nombre_produits
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY nombre_produits DESC;
