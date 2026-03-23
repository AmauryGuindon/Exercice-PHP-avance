## Exercice 4 : Connexion et CRUD en PHP

**4.1** Écrivez une classe `Database` en PHP qui gère la connexion PDO à la base `shop_e89` avec le pattern Singleton. La connexion doit :
- Utiliser le charset `utf8mb4`
- Activer le mode exception
- Définir le fetch mode par défaut à `FETCH_ASSOC`

**4.2** Écrivez une fonction PHP `getAllProducts()` qui retourne tous les produits disponibles avec le nom de leur catégorie, triés par prix décroissant.

**4.3** Écrivez une fonction PHP `getProductById($id)` qui retourne un produit par son ID avec sa catégorie et sa note moyenne. Utilisez une requête préparée.

**4.4** Écrivez une fonction PHP `createUser($firstName, $lastName, $email, $password)` qui :
- Hache le mot de passe avec `password_hash()`
- Insère l'utilisateur en base
- Retourne l'ID du nouvel utilisateur
- Gère le cas où l'email existe déjà (try/catch)

**4.5** Écrivez une fonction PHP `searchProducts($keyword)` qui recherche des produits par nom ou description (LIKE). Utilisez une requête préparée.