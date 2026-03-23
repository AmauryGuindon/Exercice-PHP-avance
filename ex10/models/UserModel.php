<?php
// ============================================================
// 10.4 models/UserModel.php
// ============================================================

require_once __DIR__ . '/../config.php';

class UserModel
{
    private PDO $pdo;

    public function __construct()
    {
        $this->pdo = Database::getInstance()->getConnection();
    }

    // Inscription avec hachage du mot de passe
    // $data = ['first_name', 'last_name', 'email', 'password', ...]
    public function register(array $data): int
    {
        try {
            $stmt = $this->pdo->prepare(
                'INSERT INTO users (first_name, last_name, email, password, city, country, birth_date)
                 VALUES (:first_name, :last_name, :email, :password, :city, :country, :birth_date)'
            );
            $stmt->execute([
                ':first_name' => $data['first_name'],
                ':last_name'  => $data['last_name'],
                ':email'      => $data['email'],
                ':password'   => password_hash($data['password'], PASSWORD_DEFAULT),
                ':city'       => $data['city']       ?? null,
                ':country'    => $data['country']    ?? 'France',
                ':birth_date' => $data['birth_date'] ?? null,
            ]);
            return (int) $this->pdo->lastInsertId();
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                throw new RuntimeException("L'adresse email '{$data['email']}' est déjà utilisée.");
            }
            throw $e;
        }
    }

    // Connexion sécurisée — retourne les données utilisateur (sans mot de passe) ou false
    public function authenticate(string $email, string $password)
    {
        $stmt = $this->pdo->prepare(
            'SELECT id, first_name, last_name, email, password, role, city, country, is_active
             FROM users
             WHERE email = :email'
        );
        $stmt->execute([':email' => $email]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($password, $user['password']) || !$user['is_active']) {
            return false;
        }

        unset($user['password']);
        return $user;
    }

    // Profil utilisateur avec statistiques (nb commandes, montant total, nb avis)
    public function getProfile(int $userId)
    {
        $stmt = $this->pdo->prepare(
            'SELECT u.id, u.first_name, u.last_name, u.email, u.role, u.city, u.country,
                    u.birth_date, u.created_at,
                    COUNT(DISTINCT o.id)    AS nb_commandes,
                    COALESCE(SUM(o.total_amount), 0) AS montant_total,
                    COUNT(DISTINCT r.id)   AS nb_avis
             FROM users u
             LEFT JOIN orders o ON u.id = o.user_id
             LEFT JOIN reviews r ON u.id = r.user_id
             WHERE u.id = :id
             GROUP BY u.id, u.first_name, u.last_name, u.email, u.role,
                      u.city, u.country, u.birth_date, u.created_at'
        );
        $stmt->execute([':id' => $userId]);
        return $stmt->fetch();
    }
}
