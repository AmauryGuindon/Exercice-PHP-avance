-- ============================================================
-- Exercice 8 : Requêtes analytiques et métier
-- ============================================================

-- 8.1 Panier moyen par mois pour 2024 (commandes non annulées)
SELECT MONTH(created_at)              AS mois,
       ROUND(AVG(total_amount), 2)    AS panier_moyen,
       COUNT(*)                       AS nombre_commandes
FROM orders
WHERE YEAR(created_at) = 2024
  AND status != 'cancelled'
GROUP BY MONTH(created_at)
ORDER BY mois;

-- 8.2 Clients fidèles : >= 2 commandes livrées ET >= 1 avis
SELECT u.first_name, u.last_name,
       COUNT(DISTINCT o.id)   AS commandes_livrees,
       SUM(o.total_amount)    AS montant_total,
       COUNT(DISTINCT r.id)   AS nombre_avis
FROM users u
JOIN orders o ON u.id = o.user_id AND o.status = 'delivered'
JOIN reviews r ON u.id = r.user_id
GROUP BY u.id, u.first_name, u.last_name
HAVING COUNT(DISTINCT o.id) >= 2
   AND COUNT(DISTINCT r.id) >= 1
ORDER BY montant_total DESC;

-- 8.3 Produits avec leurs tags concaténés (NULL ou chaîne vide si aucun tag)
SELECT p.name AS produit,
       GROUP_CONCAT(t.name ORDER BY t.name SEPARATOR ', ') AS tags
FROM products p
LEFT JOIN product_tag pt ON p.id = pt.product_id
LEFT JOIN tags t ON pt.tag_id = t.id
GROUP BY p.id, p.name
ORDER BY p.name;

-- 8.4 Évolution du stock : nom, stock actuel, quantité vendue, stock théorique initial
SELECT p.name                                   AS produit,
       p.stock                                  AS stock_actuel,
       COALESCE(SUM(oi.quantity), 0)            AS quantite_vendue,
       p.stock + COALESCE(SUM(oi.quantity), 0)  AS stock_initial_theorique
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status != 'cancelled'
GROUP BY p.id, p.name, p.stock
ORDER BY p.name;

-- 8.5 Recommandation "Les clients qui ont acheté MacBook Pro 14" (id=1) ont aussi acheté..."
SELECT p.name                  AS produit_recommande,
       COUNT(DISTINCT oi2.order_id) AS clients_en_commun
FROM order_items oi1
JOIN orders o1 ON oi1.order_id = o1.id
JOIN order_items oi2 ON o1.user_id = (
    SELECT o2.user_id FROM orders o2 WHERE o2.id = oi2.order_id
)
JOIN products p ON oi2.product_id = p.id
WHERE oi1.product_id = 1
  AND oi2.product_id != 1
  AND o1.user_id IN (
      SELECT DISTINCT o.user_id
      FROM orders o
      JOIN order_items oi ON o.id = oi.order_id
      WHERE oi.product_id = 1
  )
GROUP BY p.id, p.name
ORDER BY clients_en_commun DESC;
