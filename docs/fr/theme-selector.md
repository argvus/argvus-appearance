---
title: Sélecteur visuel de thèmes
---

Ouvrez `argvus theme-selector`, `argvus theme-switch` sans argument ou `SUPER + Shift + T`. Cette interface GTK indépendante apparaît sur le moniteur actif avec un aperçu central et les cartes voisines. Recherchez ou filtrez Tous/Sombres/Clairs; parcourez avec les flèches, la molette ou les cartes latérales. Entrée ou Appliquer confirme; Échap ou Fermer annule. Parcourir ne modifie pas le bureau. Le catalogue existant réunit thèmes système et personnels. Une image `preview` valide est prioritaire; sinon, fond et palette composent un bureau illustratif, sans reproduire exactement les personnalisations des applications. La transaction conserve Sticky/Spaced. Une erreur permet de réessayer. Les miniatures JXL utilisent `djxl` de `libjxl`; le cache XDG contient `argvus/theme-selector/v2`.

À l’ouverture du sélecteur, le focus initial est placé sur la navigation du carrousel. Appuyez sur `/` pour activer ou quitter la recherche ; la saisie filtre les thèmes lorsque la recherche a le focus. **Personnalisé** affiche les thèmes installés par l’utilisateur ; **Sombre** et **Clair** affichent les thèmes système de chaque catégorie. La ligne de recherche a la largeur de l’aperçu central. Sticky utilise des angles droits partout ; Spaced conserve les angles arrondis. Le style compact à chasse fixe s’accorde aux outils ARGVUS.

Pendant l’application, l’aperçu central est assombri et affiche un indicateur animé. La recherche utilise l’accent actif et le filtre possède une seule bordure.
