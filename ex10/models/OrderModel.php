<?php
// ============================================================
// 10.3 models/OrderModel.php
// ============================================================

require_once __DIR__ . '/../config.php';

class OrderModel
{
    private PDO $pdo;

    public function __construct()
    {
        $this->pdo = Database::getInstance()->getConnection();
    }

    // Création de commande avec transaction
    // $items = [['product_id' => X, 'quantity' => Y], ...]
    public function create(int $userId, array $items): int
    {
        if (empty($items)) {
            throw new InvalidArgumentException("La commande doit contenir au moins un article.");
        }

        $this->pdo->beginTransaction();
        try {
            $totalAmount = 0.0;
            $productData = [];

            foreach ($items as $item) {
                $stmt = $this->pdo->prepare(
                    'SELECT id, price, stock FROM products WHERE id = :id AND is_available = 1 FOR UPDATE'
                );
                $stmt->execute([':id' => $item['product_id']]);
                $product = $stmt->fetch();

                if (!$product) {
                    throw new RuntimeException("Produit ID {$item['product_id']} introuvable ou indisponible.");
                }
                if ($product['stock'] < $item['quantity']) {
                    throw new RuntimeException("Stock insuffisant pour le produit ID {$item['product_id']}.");
                }

                $productData[$item['product_id']] = $product;
                $totalAmount += $product['price'] * $item['quantity'];
            }

            $stmt = $this->pdo->prepare(
                'INSERT INTO orders (user_id, status, total_amount) VALUES (:user_id, :status, :total)'
            );
            $stmt->execute([':user_id' => $userId, ':status' => 'pending', ':total' => $totalAmount]);
            $orderId = (int) $this->pdo->lastInsertId();

            foreach ($items as $item) {
                $product = $productData[$item['product_id']];

                $stmt = $this->pdo->prepare(
                    'INSERT INTO order_items (order_id, product_id, quantity, unit_price)
                     VALUES (:order_id, :product_id, :quantity, :unit_price)'
                );
                $stmt->execute([
                    ':order_id'   => $orderId,
                    ':product_id' => $item['product_id'],
                    ':quantity'   => $item['quantity'],
                    ':unit_price' => $product['price'],
                ]);

                $this->pdo->prepare('UPDATE products SET stock = stock - :qty WHERE id = :id')
                    ->execute([':qty' => $item['quantity'], ':id' => $item['product_id']]);
            }

            $this->pdo->commit();
            return $orderId;
        } catch (Exception $e) {
            $this->pdo->rollBack();
            throw $e;
        }
    }

    // Commandes d'un utilisateur avec détail des produits
    public function getByUser(int $userId): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT o.id AS order_id, o.status, o.total_amount, o.created_at,
                    p.name AS product_name, oi.quantity, oi.unit_price
             FROM orders o
             JOIN order_items oi ON o.id = oi.order_id
             JOIN products p ON oi.product_id = p.id
             WHERE o.user_id = :user_id
             ORDER BY o.created_at DESC, o.id'
        );
        $stmt->execute([':user_id' => $userId]);
        return $stmt->fetchAll();
    }

    // Mise à jour du statut d'une commande
    public function updateStatus(int $orderId, string $status): bool
    {
        $allowed = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
        if (!in_array($status, $allowed, true)) {
            throw new InvalidArgumentException("Statut invalide : $status");
        }
        $stmt = $this->pdo->prepare('UPDATE orders SET status = :status WHERE id = :id');
        return $stmt->execute([':status' => $status, ':id' => $orderId]);
    }

    // Chiffre d'affaires mensuel pour une année donnée (commandes livrées)
    public function getMonthlySales(int $year): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT MONTH(created_at) AS mois,
                    COUNT(*)           AS nombre_commandes,
                    SUM(total_amount)  AS chiffre_affaires
             FROM orders
             WHERE YEAR(created_at) = :year
               AND status = \'delivered\'
             GROUP BY MONTH(created_at)
             ORDER BY mois'
        );
        $stmt->execute([':year' => $year]);
        return $stmt->fetchAll();
    }
}
