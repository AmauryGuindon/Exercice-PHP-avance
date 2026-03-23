-- ============================================================
-- Exercice 7 : Sous-requêtes et requêtes imbriquées
-- ============================================================

-- 7.1 Produits dont le prix est supérieur au prix moyen de leur catégorie
SELECT p.name AS produit, p.price, c.name AS categorie,
       ROUND(avg_cat.prix_moyen, 2) AS prix_moyen_categorie
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN (
    SELECT category_id, AVG(price) AS prix_moyen
    FROM products
    GROUP BY category_id
) avg_cat ON p.category_id = avg_cat.category_id
WHERE p.price > avg_cat.prix_moyen
ORDER BY c.name, p.price DESC;

-- 7.2 Clients ayant dépensé plus que la moyenne de tous les clients (commandes livrées)
SELECT u.first_name, u.last_name,
       SUM(o.total_amount) AS total_depense
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 'delivered'
GROUP BY u.id, u.first_name, u.last_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(total_par_client)
    FROM (
        SELECT SUM(total_amount) AS total_par_client
        FROM orders
        WHERE status = 'delivered'
        GROUP BY user_id
    ) sous_requete
)
ORDER BY total_depense DESC;

-- 7.3 Produits qui n'ont jamais été commandés
SELECT p.name AS produit, p.price
FROM products p
WHERE p.id NOT IN (
    SELECT DISTINCT product_id FROM order_items
)
ORDER BY p.name;

-- 7.4 Pour chaque catégorie, le produit le plus cher
SELECT c.name AS categorie, p.name AS produit, p.price
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
)
ORDER BY p.price DESC;

-- 7.5 Clients ayant commandé au moins un produit de chaque catégorie parente
-- (Informatique=1, Smartphones=5, Audio=6, Gaming=7, Photo & Vidéo=10)
SELECT u.first_name, u.last_name
FROM users u
WHERE (
    SELECT COUNT(DISTINCT
        CASE
            WHEN c.parent_id IS NULL THEN c.id
            ELSE c.parent_id
        END
    )
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN products p ON oi.product_id = p.id
    JOIN categories c ON p.category_id = c.id
    WHERE o.user_id = u.id
) = (
    SELECT COUNT(*) FROM categories WHERE parent_id IS NULL
)
ORDER BY u.last_name;
