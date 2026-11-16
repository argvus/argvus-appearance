---
title: Modes de mise en page
description: Choisissez la disposition de bureau Sticky ou Spaced.
---
Sticky garde les fenêtres et les surfaces du shell compactes. Spaced utilise des espaces plus grands, des coins arrondis et des marges de barre des tâches plus larges. Le mode de disposition est indépendant du thème sélectionné ; changer de mode réapplique la géométrie de ce mode.

Choisissez le mode dans **Panneau de configuration → Apparence → Bureau → Mode d'apparence** ou ouvrez son sélecteur avec `SUPER + Shift + M`. Le paramètre canonique est `/layout/variant`, avec les valeurs `sticky` et `spaced`. Les ID de thème Spaced résolus utilisent le suffixe `-spaced`. Les valeurs existantes `float` et les ID `-float` restent lisibles pour compatibilité.

`argvus layout-mode-menu` (SUPER + Shift + M): Choisissez Sticky ou Spaced avec ↑/↓. Les quatre cartes à droite combinent fenêtres en mosaïque ou flottantes et barre en haut ou en bas ; ←/→ les parcourt sans boucle. Cliquez pour choisir, Entrée pour appliquer ou Échap pour annuler. Le mode non sélectionné est atténué ; les aperçus utilisent le thème et le fond actuels. Les applications en attente restent visibles et les erreurs permettent de réessayer.
