## Exercice 9 : Requêtes expertes

**9.1 — Classement des clients par chiffre d'affaires avec rang**
Affichez le classement des clients par montant total dépensé (commandes livrées). Affichez le rang, le nom du client, le montant total, et le pourcentage du CA total que représente ce client.

**9.2 — Catégories avec hiérarchie complète**
Affichez toutes les catégories avec leur chemin complet. Par exemple : "Informatique > Ordinateurs portables", "Gaming > Consoles". Les catégories racines affichent juste leur nom.

**9.3 — Cohorte d'achat**
Pour chaque mois d'inscription des utilisateurs, calculez combien ont passé leur première commande dans le mois suivant leur inscription, dans les 2 mois, dans les 3 mois, ou jamais.

**9.4 — Détection d'anomalies**
Écrivez une requête qui détecte les incohérences dans les données :
- Commandes dont le `total_amount` ne correspond pas à la somme des `order_items` (quantité × prix unitaire)
- Produits avec un stock négatif
- Utilisateurs inactifs qui ont des commandes en cours (pending ou confirmed)

**9.5 — Tableau de bord complet**
En une seule requête (ou avec des sous-requêtes), affichez un résumé de la boutique :
- Nombre total de clients actifs
- Nombre total de commandes (hors annulées)
- Chiffre d'affaires total (commandes livrées)
- Panier moyen
- Produit le plus vendu (nom)
- Meilleur client (nom + montant)