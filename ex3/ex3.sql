-- ============================================================
-- Exercice 3 : Premières jointures (JOIN)
-- ============================================================

-- 3.1 Liste des commandes avec le prénom et nom du client
SELECT o.id AS commande_id, u.first_name, u.last_name, o.status, o.total_amount, o.created_at
FROM orders o
JOIN users u ON o.user_id = u.id
ORDER BY o.created_at DESC;

-- 3.2 Liste des produits avec le nom de leur catégorie
SELECT p.name AS produit, c.name AS categorie, p.price
FROM products p
JOIN categories c ON p.category_id = c.id
ORDER BY c.name, p.name;

-- 3.3 Avis avec le nom du produit et le prénom de l'utilisateur
SELECT r.rating, r.comment, p.name AS produit, u.first_name AS utilisateur, r.created_at
FROM reviews r
JOIN products p ON r.product_id = p.id
JOIN users u ON r.user_id = u.id
ORDER BY r.created_at DESC;

-- 3.4 Sous-catégories avec le nom de leur catégorie parente (auto-jointure)
SELECT enfant.name AS sous_categorie, parent.name AS categorie_parente
FROM categories enfant
JOIN categories parent ON enfant.parent_id = parent.id
ORDER BY parent.name, enfant.name;

-- 3.5 Produits qui n'ont aucun avis (LEFT JOIN)
SELECT p.name AS produit, p.price
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
WHERE r.id IS NULL
ORDER BY p.name;
