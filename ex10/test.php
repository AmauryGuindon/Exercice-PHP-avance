<?php
// ============================================================
// 10.5 test.php — Vérifie toutes les méthodes des modèles
// ============================================================

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/models/ProductModel.php';
require_once __DIR__ . '/models/OrderModel.php';
require_once __DIR__ . '/models/UserModel.php';

function section(string $title): void
{
    echo "\n" . str_repeat('=', 60) . "\n";
    echo "  $title\n";
    echo str_repeat('=', 60) . "\n";
}

function dump(mixed $data): void
{
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
}

// ---- ProductModel ----
section('ProductModel::getAll (page 1, 5 par page)');
$productModel = new ProductModel();
dump($productModel->getAll(1, 5));

section('ProductModel::getById (id=1 — MacBook Pro 14")');
dump($productModel->getById(1));

section('ProductModel::search (keyword="sony", prix 0–500)');
dump($productModel->search('sony', 0, 500));

section('ProductModel::getTopSellers (top 3)');
dump($productModel->getTopSellers(3));

// ---- OrderModel ----
section('OrderModel::getByUser (userId=2 — Bob)');
$orderModel = new OrderModel();
dump($orderModel->getByUser(2));

section('OrderModel::getMonthlySales (2024)');
dump($orderModel->getMonthlySales(2024));

section('OrderModel::updateStatus (order 3 -> confirmed)');
$result = $orderModel->updateStatus(3, 'confirmed');
echo 'Mise à jour : ' . ($result ? 'OK' : 'ERREUR') . "\n";

section('OrderModel::create (userId=2, MacBook Pro x1 + Manette PS5 x2)');
try {
    $newOrderId = $orderModel->create(2, [
        ['product_id' => 1,  'quantity' => 1],
        ['product_id' => 20, 'quantity' => 2],
    ]);
    echo "Commande créée avec l'ID : $newOrderId\n";
} catch (RuntimeException $e) {
    echo 'Erreur : ' . $e->getMessage() . "\n";
}

// ---- UserModel ----
section('UserModel::getProfile (userId=2 — Bob)');
$userModel = new UserModel();
dump($userModel->getProfile(2));

section('UserModel::register (nouvel utilisateur test)');
try {
    $newId = $userModel->register([
        'first_name' => 'Test',
        'last_name'  => 'Utilisateur',
        'email'      => 'test.utilisateur@email.com',
        'password'   => 'motdepasse123',
        'city'       => 'Paris',
    ]);
    echo "Utilisateur créé avec l'ID : $newId\n";
} catch (RuntimeException $e) {
    echo 'Erreur : ' . $e->getMessage() . "\n";
}

section('UserModel::authenticate (email/password invalides — doit échouer)');
$auth = $userModel->authenticate('bob.dupont@email.com', 'mauvaismdp');
echo 'Résultat : ' . ($auth ? 'Connecté' : 'Échec (attendu)') . "\n";

section('UserModel::authenticate (utilisateur inactif — doit échouer)');
$authInactive = $userModel->authenticate('laura.fontaine@email.com', 'password123');
echo 'Résultat : ' . ($authInactive ? 'Connecté' : 'Échec (attendu — compte inactif)') . "\n";
