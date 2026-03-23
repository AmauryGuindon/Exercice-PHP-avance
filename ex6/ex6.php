<?php
// ============================================================
// Exercice 6 : Transactions et sécurité en PHP
// (nécessite la classe Database de l'exercice 4)
// ============================================================

require_once __DIR__ . '/../ex4/ex4.php';

// 6.1 Crée une commande complète dans une transaction
// $items = [['product_id' => X, 'quantity' => Y], ...]
function createOrder(int $userId, array $items): int
{
    $pdo = Database::getInstance()->getConnection();
    $pdo->beginTransaction();

    try {
        $totalAmount = 0.0;
        $productData = [];

        // 1. Vérifier stock et récupérer les prix
        foreach ($items as $item) {
            $stmt = $pdo->prepare(
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

        // 2. Créer la commande
        $stmt = $pdo->prepare(
            'INSERT INTO orders (user_id, status, total_amount) VALUES (:user_id, :status, :total_amount)'
        );
        $stmt->execute([
            ':user_id'      => $userId,
            ':status'       => 'pending',
            ':total_amount' => $totalAmount,
        ]);
        $orderId = (int) $pdo->lastInsertId();

        // 3. Créer les lignes de commande + décrémenter le stock
        foreach ($items as $item) {
            $product = $productData[$item['product_id']];

            $stmt = $pdo->prepare(
                'INSERT INTO order_items (order_id, product_id, quantity, unit_price)
                 VALUES (:order_id, :product_id, :quantity, :unit_price)'
            );
            $stmt->execute([
                ':order_id'   => $orderId,
                ':product_id' => $item['product_id'],
                ':quantity'   => $item['quantity'],
                ':unit_price' => $product['price'],
            ]);

            $stmt = $pdo->prepare(
                'UPDATE products SET stock = stock - :quantity WHERE id = :id'
            );
            $stmt->execute([
                ':quantity' => $item['quantity'],
                ':id'       => $item['product_id'],
            ]);
        }

        $pdo->commit();
        return $orderId;

    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}

// 6.2 Authentifie un utilisateur par email + mot de passe
// Retourne les infos (sans le mot de passe) ou false
function authenticateUser(string $email, string $password): array|false
{
    $pdo = Database::getInstance()->getConnection();
    $stmt = $pdo->prepare(
        'SELECT id, first_name, last_name, email, password, role, city, country, is_active
         FROM users
         WHERE email = :email'
    );
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch();

    // Message générique : ne révèle pas si c'est l'email ou le mot de passe qui est incorrect
    if (!$user || !password_verify($password, $user['password'])) {
        return false;
    }

    unset($user['password']);
    return $user;
}
