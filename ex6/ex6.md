## Exercice 6 : Transactions et sécurité en PHP

**6.1** Écrivez une fonction PHP `createOrder($userId, $items)` qui crée une commande complète dans une transaction :
- `$items` est un tableau de `['product_id' => X, 'quantity' => Y]`
- La fonction doit :
  1. Vérifier que chaque produit existe et a assez de stock
  2. Créer la commande dans `orders`
  3. Créer les lignes dans `order_items` avec le prix unitaire récupéré du produit
  4. Calculer et mettre à jour le `total_amount` de la commande
  5. Décrémenter le stock de chaque produit
  6. Tout annuler (rollback) si une étape échoue

**6.2** Écrivez une fonction PHP `authenticateUser($email, $password)` qui :
- Récupère l'utilisateur par email
- Vérifie le mot de passe avec `password_verify()`
- Retourne les infos de l'utilisateur (sans le mot de passe) ou `false`
- Ne révèle pas si c'est l'email ou le mot de passe qui est incorrect