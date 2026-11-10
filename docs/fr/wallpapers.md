---
title: Papiers peints
description: Utilisez des fonds d'écran ARGVUS intégrés et personnalisés.
---
Les fonds d'écran JPEG XL intégrés sont installés par `argvus-wallpapers` sous `/usr/share/backgrounds/argvus/`. Dans **Centre de contrôle → Apparence → Fonds d'écran**, ils sont organisés comme `Abstract` ou `Landscape`, puis par `Dark` ou `Light`. Les fichiers racine `argvus-dark.jxl` et `argvus-light.jxl` apparaissent sous les groupes de secours abstraits. Le changement de thème utilise uniquement les fichiers abstraits dans `abstract/dark` et `abstract/light` ; les fichiers paysage sont des choix manuels optionnels. Appuyez sur `SUPER + Y` pour ouvrir directement cet écran du Centre de contrôle. La première entrée accepte également une image personnalisée depuis HOME ; le fichier sélectionné devient l'état de fond d'écran personnalisé de l'utilisateur.

La première entrée ouvre un sélecteur de fichiers pour une image personnalisée. Un fond d'écran personnalisé sélectionné est stocké sous `/appearance/wallpaper` avec `/appearance/wallpaper_custom` dans la configuration canonique, et `argvus config` le projette dans la configuration de fond d'écran Hyprland utilisée par la session. Il reste actif jusqu'à ce qu'un changement de thème ou de mode réapplique le fond d'écran de ce thème. Exportez le thème actif pour inclure le fond d'écran actuel et le conserver dans le thème exporté. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` est uniquement une entrée de migration héritée.

Lorsqu'un thème est exporté, l'image du fond d'écran actuel est incluse lorsqu'elle est lisible. L'importation installe le thème ; son application active son fond d'écran. Voir [Importation et exportation de thèmes](/docs/components/argvus-themes/import-and-export/).

Les contrôles d'apparence destinés à l'utilisateur utilisent l'assistant Hyprland `hypr-wallpaper-pick.sh`, qui valide le chemin choisi via `argvus config` au lieu de stocker l'état du fond d'écran lui-même. Ne modifiez pas directement la configuration du fond d'écran générée.
