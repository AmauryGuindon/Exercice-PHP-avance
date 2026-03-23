## Exercice 8 : Requêtes analytiques et métier

**8.1 — Panier moyen**
Calculez le panier moyen (montant moyen par commande) par mois pour l'année 2024. Affichez le mois et le panier moyen. Ne comptez que les commandes non annulées.

**8.2 — Clients fidèles**
Affichez les clients qui ont passé au moins 2 commandes livrées ET qui ont laissé au moins 1 avis. Affichez leur nom, le nombre de commandes livrées, le montant total dépensé, et le nombre d'avis.

**8.3 — Produits avec tous leurs tags**
Affichez chaque produit avec la liste de ses tags concaténés en une seule chaîne (séparés par des virgules). Les produits sans tag doivent aussi apparaître avec NULL ou une chaîne vide.

**8.4 — Évolution du stock**
Écrivez une requête qui affiche pour chaque produit : son nom, son stock actuel, la quantité totale vendue (toutes commandes non annulées), et le stock théorique initial (stock actuel + quantité vendue).

**8.5 — Recommandation "Les clients qui ont acheté X ont aussi acheté..."**
Pour le produit "MacBook Pro 14"" (id=1), trouvez les autres produits achetés par les clients qui ont aussi acheté ce MacBook. Affichez le nom du produit recommandé et le nombre de clients en commun. Excluez le MacBook lui-même.
