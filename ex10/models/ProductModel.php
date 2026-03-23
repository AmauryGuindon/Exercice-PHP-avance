<?php
// ============================================================
// 10.2 models/ProductModel.php
// ============================================================

require_once __DIR__ . '/../config.php';

class ProductModel
{
    private PDO $pdo;

    public function __construct()
    {
        $this->pdo = Database::getInstance()->getConnection();
    }

    // Liste paginée des produits avec leur catégorie
    public function getAll(int $page = 1, int $perPage = 10): array
    {
        $offset = ($page - 1) * $perPage;
        $stmt = $this->pdo->prepare(
            'SELECT p.id, p.name, p.price, p.stock, c.name AS category
             FROM products p
             JOIN categories c ON p.category_id = c.id
             WHERE p.is_available = 1
             ORDER BY p.name
             LIMIT :limit OFFSET :offset'
        );
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    // Détail d'un produit avec catégorie, note moyenne et tags
    public function getById(int $id)
    {
        $stmt = $this->pdo->prepare(
            'SELECT p.id, p.name, p.description, p.price, p.stock,
                    c.name AS category,
                    ROUND(AVG(r.rating), 2) AS average_rating,
                    GROUP_CONCAT(t.name ORDER BY t.name SEPARATOR ", ") AS tags
             FROM products p
             JOIN categories c ON p.category_id = c.id
             LEFT JOIN reviews r ON p.id = r.product_id
             LEFT JOIN product_tag pt ON p.id = pt.product_id
             LEFT JOIN tags t ON pt.tag_id = t.id
             WHERE p.id = :id
             GROUP BY p.id, p.name, p.description, p.price, p.stock, c.name'
        );
        $stmt->execute([':id' => $id]);
        return $stmt->fetch();
    }

    // Recherche avec filtres multiples (mot-clé, prix min/max)
    public function search(string $keyword = '', float $minPrice = 0, float $maxPrice = PHP_FLOAT_MAX): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT p.id, p.name, p.price, c.name AS category
             FROM products p
             JOIN categories c ON p.category_id = c.id
             WHERE p.is_available = 1
               AND (p.name LIKE :keyword_name OR p.description LIKE :keyword_desc)
               AND p.price >= :min_price
               AND p.price <= :max_price
             ORDER BY p.price'
        );
        $pattern = '%' . $keyword . '%';
        $stmt->execute([
            ':keyword_name' => $pattern,
            ':keyword_desc' => $pattern,
            ':min_price'    => $minPrice,
            ':max_price'    => $maxPrice,
        ]);
        return $stmt->fetchAll();
    }

    // Top des produits les plus vendus
    public function getTopSellers(int $limit = 5): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT p.id, p.name, p.price, SUM(oi.quantity) AS total_sold
             FROM products p
             JOIN order_items oi ON p.id = oi.product_id
             GROUP BY p.id, p.name, p.price
             ORDER BY total_sold DESC
             LIMIT :limit'
        );
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
