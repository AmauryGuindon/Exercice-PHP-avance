-- ============================================================
-- Exercice 9 : Requêtes expertes
-- ============================================================

-- 9.1 Classement des clients par CA avec rang et % du CA total (commandes livrées)
SELECT RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS rang,
       u.first_name,
       u.last_name,
       SUM(o.total_amount)                             AS montant_total,
       ROUND(
           SUM(o.total_amount) * 100.0 /
           (SELECT SUM(total_amount) FROM orders WHERE status = 'delivered'),
           2
       )                                               AS pourcentage_ca
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 'delivered'
GROUP BY u.id, u.first_name, u.last_name
ORDER BY rang;

-- 9.2 Catégories avec chemin complet (sous-catégories : "Parent > Enfant")
SELECT
    CASE
        WHEN c.parent_id IS NULL THEN c.name
        ELSE CONCAT(parent.name, ' > ', c.name)
    END AS chemin_complet
FROM categories c
LEFT JOIN categories parent ON c.parent_id = parent.id
ORDER BY chemin_complet;

-- 9.3 Cohorte d'achat : par mois d'inscription, combien ont commandé dans le mois suivant,
--     dans les 2 mois, les 3 mois, ou jamais
SELECT DATE_FORMAT(u.created_at, '%Y-%m')     AS mois_inscription,
       COUNT(u.id)                             AS nb_inscrits,
       SUM(CASE WHEN TIMESTAMPDIFF(MONTH, u.created_at, first_order.first_order_date) <= 1
                THEN 1 ELSE 0 END)             AS commande_mois_1,
       SUM(CASE WHEN TIMESTAMPDIFF(MONTH, u.created_at, first_order.first_order_date) <= 2
                THEN 1 ELSE 0 END)             AS commande_mois_2,
       SUM(CASE WHEN TIMESTAMPDIFF(MONTH, u.created_at, first_order.first_order_date) <= 3
                THEN 1 ELSE 0 END)             AS commande_mois_3,
       SUM(CASE WHEN first_order.first_order_date IS NULL
                THEN 1 ELSE 0 END)             AS jamais_commande
FROM users u
LEFT JOIN (
    SELECT user_id, MIN(created_at) AS first_order_date
    FROM orders
    GROUP BY user_id
) first_order ON u.id = first_order.user_id
GROUP BY DATE_FORMAT(u.created_at, '%Y-%m')
ORDER BY mois_inscription;

-- 9.4 Détection d'anomalies

-- 9.4a Commandes dont total_amount != somme des order_items
SELECT o.id                                    AS commande_id,
       o.total_amount                          AS total_en_base,
       SUM(oi.quantity * oi.unit_price)        AS total_calcule,
       o.total_amount - SUM(oi.quantity * oi.unit_price) AS ecart
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.quantity * oi.unit_price)) > 0.01;

-- 9.4b Produits avec stock négatif
SELECT id, name, stock
FROM products
WHERE stock < 0;

-- 9.4c Utilisateurs inactifs (is_active = 0) avec des commandes pending ou confirmed
SELECT u.id, u.first_name, u.last_name, u.is_active,
       o.id AS commande_id, o.status
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.is_active = 0
  AND o.status IN ('pending', 'confirmed');

-- 9.5 Tableau de bord complet en une requête
SELECT
    (SELECT COUNT(*) FROM users WHERE is_active = 1)                          AS clients_actifs,
    (SELECT COUNT(*) FROM orders WHERE status != 'cancelled')                  AS total_commandes,
    (SELECT SUM(total_amount) FROM orders WHERE status = 'delivered')          AS chiffre_affaires,
    (SELECT ROUND(AVG(total_amount), 2) FROM orders WHERE status != 'cancelled') AS panier_moyen,
    (SELECT p.name
     FROM products p
     JOIN order_items oi ON p.id = oi.product_id
     GROUP BY p.id, p.name
     ORDER BY SUM(oi.quantity) DESC
     LIMIT 1)                                                                  AS produit_plus_vendu,
    (SELECT CONCAT(u.first_name, ' ', u.last_name)
     FROM users u
     JOIN orders o ON u.id = o.user_id
     WHERE o.status = 'delivered'
     GROUP BY u.id, u.first_name, u.last_name
     ORDER BY SUM(o.total_amount) DESC
     LIMIT 1)                                                                  AS meilleur_client,
    (SELECT SUM(o2.total_amount)
     FROM orders o2
     JOIN users u2 ON o2.user_id = u2.id
     WHERE o2.status = 'delivered'
     GROUP BY u2.id
     ORDER BY SUM(o2.total_amount) DESC
     LIMIT 1)                                                                  AS montant_meilleur_client;
