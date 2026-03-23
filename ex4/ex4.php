<?php
// ============================================================
// Exercice 4 : Connexion et CRUD en PHP
// ============================================================

// 4.1 Classe Database — connexion PDO avec pattern Singleton
class Database
{
    private static ?Database $instance = null;
    private PDO $pdo;

    private function __construct()
    {
        $dsn = 'mysql:host=localhost;dbname=shop_e89;charset=utf8mb4';
        $this->pdo = new PDO($dsn, 'root', '', [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }

    public static function getInstance(): Database
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection(): PDO
    {
        return $this->pdo;
    }
}

// 4.2 Retourne tous les produits disponibles avec le nom de leur catégorie, triés par prix décroissant
function getAllProducts(): array
{
    $pdo = Database::getInstance()->getConnection();
    $stmt = $pdo->query(
        'SELECT p.id, p.name, p.price, p.stock, c.name AS category
         FROM products p
         JOIN categories c ON p.category_id = c.id
         WHERE p.is_available = 1
         ORDER BY p.price DESC'
    );
    return $stmt->fetchAll();
}

// 4.3 Retourne un produit par son ID avec sa catégorie et sa note moyenne
function getProductById(int $id): array|false
{
    $pdo = Database::getInstance()->getConnection();
    $stmt = $pdo->prepare(
        'SELECT p.id, p.name, p.description, p.price, p.stock,
                c.name AS category,
                ROUND(AVG(r.rating), 2) AS average_rating
         FROM products p
         JOIN categories c ON p.category_id = c.id
         LEFT JOIN reviews r ON p.id = r.product_id
         WHERE p.id = :id
         GROUP BY p.id, p.name, p.description, p.price, p.stock, c.name'
    );
    $stmt->execute([':id' => $id]);
    return $stmt->fetch();
}

// 4.4 Crée un utilisateur, hache le mot de passe, retourne l'ID inséré
function createUser(string $firstName, string $lastName, string $email, string $password): int
{
    $pdo = Database::getInstance()->getConnection();
    try {
        $stmt = $pdo->prepare(
            'INSERT INTO users (first_name, last_name, email, password)
             VALUES (:first_name, :last_name, :email, :password)'
        );
        $stmt->execute([
            ':first_name' => $firstName,
            ':last_name'  => $lastName,
            ':email'      => $email,
            ':password'   => password_hash($password, PASSWORD_DEFAULT),
        ]);
        return (int) $pdo->lastInsertId();
    } catch (PDOException $e) {
        // Code 23000 = violation de contrainte unique (email déjà existant)
        if ($e->getCode() === '23000') {
            throw new RuntimeException("L'adresse email '$email' est déjà utilisée.");
        }
        throw $e;
    }
}

// 4.5 Recherche des produits par nom ou description avec LIKE (requête préparée)
function searchProducts(string $keyword): array
{
    $pdo = Database::getInstance()->getConnection();
    $stmt = $pdo->prepare(
        'SELECT p.id, p.name, p.description, p.price, c.name AS category
         FROM products p
         JOIN categories c ON p.category_id = c.id
         WHERE p.name LIKE :keyword
            OR p.description LIKE :keyword
         ORDER BY p.name'
    );
    $stmt->execute([':keyword' => '%' . $keyword . '%']);
    return $stmt->fetchAll();
}
