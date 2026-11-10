---
title: Effets
description: Configurez les animations, le flou global de Hyprland et la transparence par surface.
---
**Centre de Contrôle → Hyprland** contient **Animations**, **Flou** et **Bords**, dont la page **Ombre** contrôle l'ombre des fenêtres. Les interrupteurs d'activation de la transparence sont des réglages par surface dans leurs pages d'Apparence respectives.

Les interrupteurs de surface sont indépendants. La page de configuration du Centre de Contrôle possède sa propre valeur de Transparence et un interrupteur d'activation du Flou ; son flou utilise les valeurs globales de Flou.

Le Centre de Contrôle est lancé via Foot avec un profil généré dédié à `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. Avec Foot 1.28, la transparence est projetée sur `[colors-dark] alpha` et l'interrupteur de Flou de la surface sur `[colors-dark] blur` ; la configuration normale de Foot et le terminal ARGVUS restent indépendants.

## Interrupteurs des Animations et Effets

Il y a deux interrupteurs principaux indépendants, tous deux appliqués à `hyprland.lua` via les paramètres canoniques `/effects` :

- **Animations** (`/effects/animations`) contrôle tout ce qui bouge : espace de travail, fenêtre, fondu, bordure et animations de calque.
- **Effets** est un raccourci pour le flou (`/effects/blur_global_enabled`) et la transparence de Terminal, Launcher, Widget Telemetry, Panneau de configuration et barre des tâches (`/effects/transparency_<surface>_enabled`). L'activer ou le désactiver applique le changement à tous (ainsi qu'à la transparence du Centre de contrôle). Chaque surface conserve sa propre page de transparence, donc Effets apparaît comme **activé lorsque au moins un d'entre eux est activé** et comme désactivé uniquement lorsque tous sont désactivés.

Utilisez `argvus effects-toggle animations status|enable|disable|toggle` et `argvus effects-toggle effects status|enable|disable|toggle`. La carte Apparence du Panneau de Contrôle montre un interrupteur pour chacun. Éteindre un interrupteur maître conserve tous les réglages fins des pages **Animations** et **Flou** (vitesses, courbes, interrupteurs par feuille, taille et passes du flou), donc le rallumer restaure le même aspect. `effects status` imprime `enabled` lorsque le flou ou au moins une de ces surfaces de transparence est activée. Désactiver la transparence d'une surface rend toute la surface de Waybar opaque : en plus de l'arrière-plan, les bordures translucides de la barre des tâches et de la Widget Télémetry prennent la couleur unie qu'elles montrent sur l'arrière-plan du thème. Chaque effet est activé par défaut lors d'une nouvelle installation, y compris sur les machines virtuelles et les sessions à faible consommation ; seule une configuration explicite permet de les désactiver.

## Tous les effets à la fois

`argvus effects-toggle` sans composant agit sur les animations, le flou et la transparence ensemble : `status` imprime `enabled` uniquement lorsque les trois sont activés, `enable` et `disable` basculent les trois, et `toggle` éteint tout lorsque `status` est `enabled` et allume sinon. **SUPER + F6** exécute ce basculement. Pour agir sur un seul groupe, nommez-le : `argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`. La page **Animations** du Centre de Contrôle utilise la forme par composant, donc son interrupteur **Activer** ne change toujours que les animations.

## Transparence

Chaque surface dispose de son propre sous-menu **Transparence** avec un interrupteur d'activation et une valeur.

La page **Apparence → Lanceurs** contrôle le lanceur officiel basé sur Rofi et les flux de sélection : le lanceur principal, le sélecteur d'emojis, la calculatrice, le sélecteur de presse-papiers, les feuilles de triche et les menus de périphériques amovibles Rofi. Sa valeur de Transparence correspond à l'alpha final de l'arrière-plan, donc `50` signifie une opacité d'arrière-plan effective d'environ `0.50` ; le texte, les icônes et les lignes sélectionnées restent opaques. Lorsque la Transparence est désactivée, le lanceur utilise la couleur d'arrière-plan du thème actif, totalement opaque. Son option Flou applique la couche `rofi` aux paramètres globaux de flou.

Chaque valeur varie de `0%` (opaque) à `100%` (totalement transparent). Utilisez `+` et `-` par paliers de 5 %, puis sélectionnez **Appliquer** sur la page de surface. Quitter la page supprime les brouillons non appliqués.

Utilisez `↑` et `↓` pour passer entre **Activer** et **Valeur**. Sur la ligne **Valeur**, `+` et `-` ajustent le brouillon sans changer le focus. Appuyez sur `Tab` pour ouvrir **Actions**, puis activez **[ Appliquer ]** ; `Esc` revient à la page de surface parente.

## Animations

Ouvrez **Centre de Contrôle → Hyprland → Animations**. La page dispose d’un interrupteur **Activer** et d’une liste **Options** avec **Courbes personnalisées** et cinq catégories. Chaque catégorie liste ses animations, et chaque animation a sa propre page avec **Style**, **Vitesse**, **Courbe** et, pour l’ouverture et la fermeture des fenêtres, **Pourcentage d’apparition**. Les animations que Hyprland peut désactiver ont également une ligne **Activer**.

Chaque valeur sur ces pages appartient à un seul brouillon partagé par tout l'arbre d'Animations. Rien n'est écrit tant que **[ Appliquer ]** n'est pas sélectionné en bas de l'une d'elles. Naviguer entre les pages conserve le brouillon ; quitter la page Animations avec un brouillon non appliqué demande une confirmation. Appliquer écrit les valeurs modifiées en un seul appel et recharge Hyprland. L'interrupteur **Activer** en haut est l'état global de l'animation (`effects.animations`) : lorsqu'il est désactivé, toutes les animations sont désactivées, quel que soit leur propre interrupteur.

Contrôles : `↑/↓` se déplace entre les lignes ; `←/→` (ou `+/-`) change la valeur sélectionnée et fait défiler **Style** et **Courbe** ; `Enter` permet de saisir une **Vitesse**, un **Pourcentage d'apparition** ou un paramètre de courbe exact (les valeurs hors limites sont refusées), et fait défiler **Style** et **Courbe** vers l'avant.

### Catégories et animations

| Catégorie | Animation | Touche (`effects.animation_<key>_*`) | Style (par défaut) | Vitesse | Activer |
|---|---|---|---|---|---|
| Fenêtres | Ouverture des fenêtres | `opening` | `popin`, pop-in 87% | 4.1 | — |
| Fenêtres | Fermeture des fenêtres | `closing` | `popin`, pop-in 87% | 1,49 | — |
| Fenêtres | Déplacement des fenêtres | `moving` | — | 4,79 | oui |
| Espaces de travail | Changer d'espace de travail | `switching` | `fade` | 1,94 | — |
| Espaces de travail | Entrée de l'espace de travail | `workspace_in` | `fade` | 1.21 | — |
| Espaces de travail | Sortie de l'espace de travail | `workspace_out` | `fade` | 1,94 | — |
| Espaces de travail | Espaces de travail spéciaux | `special_workspace` | `slide` | 5 | — |
| Calques et fenêtres contextuelles | Surfaces de calque | `layers` | — | 3,81 | oui |
| Calques et fenêtres contextuelles | Entrée de couche | `layers_in` | `fade` | 4 | — |
| Calques et fenêtres contextuelles | Sortie de couche | `layers_out` | `fade` | 1.5 | — |
| Calques et fenêtres contextuelles | Fondu | `fade` | — | 3.03 | oui |
| Calques et fenêtres contextuelles | Fondu entrant | `fade_in` | — | 1,73 | oui |
| Calques et fenêtres contextuelles | Fondu | `fade_out` | — | 1,46 | oui |
| Bordures & effets | Couleur de la bordure | `border` | — | 5.39 | oui |
| Bordures et effets | Angle du dégradé de bordure | `border_angle` | — | 5 | oui |
| Autres animations | Facteur de zoom | `zoom` | — | 7 | oui |
| Autres animations | Moniteur ajouté | `monitor_added` | — | 5 | oui |

Les valeurs par défaut des feuilles fournies avec Hyprland 0.56.2 dans sa configuration d'origine (toutes les lignes sauf Espaces de travail spéciaux, Angle du dégradé de bordure et Moniteur ajouté) sont les vitesses, styles et courbes d'origine. Ces trois éléments conservent les valeurs par défaut ARGVUS, car la configuration d'origine ne les définit pas.

Chaque feuille offre uniquement les styles que Hyprland 0.56.2 accepte pour elle. L'ouverture et la fermeture des fenêtres proposent `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` et `gnomed`. L'entrée et la sortie des calques proposent `slide`, `popin`, `fade`, `slidefade`, `slidevert` et `slidefadevert`. Les feuilles des espaces de travail (changement, entrée, sortie et espaces de travail spéciaux) proposent `slide`, `fade`, `slidefade`, `slidevert` et `slidefadevert`, sans `popin` ni `gnomed`. Un style enregistré en dehors de la liste de sa feuille est ignoré et la feuille utilise son style par défaut. Chaque animation commence avec la courbe `default`. Une page n’offre que les lignes supportées par son animation. Les clés enregistrées sont `effects.animation_<key>_speed`, `_curve`, `_style` (lorsqu’elles sont proposées), `_popin` (ouverture et fermeture de fenêtres) et `_enabled` (lorsqu’elles sont proposées).

### Courbes

| Courbe | Comportement | Paramètres (clé → défaut) |
|---|---|---|
| `default` | La courbe Hyprland 0.56.2 fournie pour cette animation (par exemple `easeOutQuint`, `almostLinear`, `quick`, `linear` ou le ressort `easy`). Les animations sans courbe standard utilisent le Bézier intégré de ARGVUS. | Fixe. |
| `bezier` | Mouvement fluide qui accélère et décélère, façonné par deux points de contrôle. | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Mouvement physique avec masse, rigidité et amortissement ; il peut dépasser pour un effet élastique. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | Vitesse constante pour toute l'animation, de `(0, 0)` à `(1, 1)`. | Fixe. |
| `ease_out` | Rapide au début et lisse à la fin, de `(0, 0)` à `(0.58, 1)`. | Fixe. |

Sous **Courbes personnalisées**, chaque courbe a sa propre page. Bézier édite ses quatre points de contrôle, Spring édite la masse, la raideur et l'amortissement, et Linear et Ease-out montrent leurs points fixes. Les valeurs de Bézier et Spring s'appliquent à chaque animation qui sélectionne cette courbe.

Plages et pas : **Vitesse** 1–10 avec des décimales (pas 0,1, les vitesses par défaut sont décimales) ; **Pourcentage de pop-in** 1–100 en nombres entiers (pas 5, par défaut 87) ; points Bézier comme ci-dessus (pas 0,05) ; masse Spring 0,5–10 (pas 0,1), raideur 0,5–2000 (pas 10) et amortissement 0,5–200 (pas 1).

Non offert : Hyprland 0.56.2 n’a pas d’animation séparée pour le redimensionnement des fenêtres, pour les pop-ups, ni pour les angles du dégradé d’ombre et de lueur, donc la page ne montre pas de lignes pour ceux-ci.

## Flou

Le flou est un paramètre global de Hyprland, partagé par toutes les surfaces qui y optent. Ouvrez **Panneau de contrôle → Hyprland → Flou**. La page contient un interrupteur **Activer** et une liste **Valeurs** avec les paramètres de `decoration:blur` de Hyprland, sous les noms utilisés par Hyprland :

| Ligne | Clé de configuration | Valeur par défaut | Plage | Pas `←/→` |
|---|---|---|---|---|
| Taille | `effects.blur_size` | `6` | 1–64 | 1 |
| Passages | `effects.blur_passes` | `2` | 1–8 | 1 |
| Luminosité | `effects.blur_brightness` | `1` | 0–2 | 0,05 |
| Bruit | `effects.blur_noise` | `0.00` | 0–1 | 0,01 |
| Contraste | `effects.blur_contrast` | `0.900000` | 0–2 | 0,05 |
| Vibrance | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0,01 |
| Obscurité de la vibrance | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0,01 |

Utilisez `↑/↓` pour déplacer, `←/→` (ou `+/-`) pour changer la valeur sélectionnée par son pas, et `Enter` pour saisir une valeur exacte ; les valeurs hors de l'intervalle sont refusées. Rien n'est écrit pendant que vous modifiez : l'interrupteur et les valeurs restent dans le brouillon jusqu'à ce que **[ Appliquer ]** en bas de la page soit sélectionné. Appliquer écrit chaque valeur modifiée en un seul appel, et recharge Hyprland après. Quitter la page avec un brouillon non appliqué demande une confirmation.

Les valeurs sont transmises à Hyprland telles quelles ; ARGVUS ne les dérive pas d'un pourcentage. Modifier l'interrupteur d'une surface ne change pas les valeurs.

## Ombre

L'ombre de la fenêtre est un paramètre global de Hyprland, sous **Centre de contrôle → Hyprland → Bordures → Ombre**. Elle est indépendante de la transparence et du flou : elle est désactivée par défaut, et activer ou désactiver la transparence d'une surface ne la modifie pas.

| Ligne | Clé de configuration | Par défaut | Plage | Étape `←/→` |
|---|---|---|---|---|
| Activer | `effects.shadow_enabled` | `false` | — | — |
| Netteté | `effects.shadow_sharp` | `false` | — | — |
| Couleur | `effects.shadow_color` | vide (suit l'accent) | vide ou `RRGGBBAA` | — |
| Plage | `effects.shadow_range` | `6` | 0–100 | 1 |
| Puissance de rendu | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| Décalage X | `effects.shadow_offset_x` | `0` | −100 à 100 | 1 |
| Décalage Y | `effects.shadow_offset_y` | `0` | −100 à 100 | 1 |
| Échelle | `effects.shadow_scale` | `1.00` | 0–1 | 0,05 |

Une couleur vide suit l’accent du thème actif avec alpha `99`, donc l’accent bleu par défaut donne `3590bd99`. Tapez huit chiffres hexadécimaux (`RRGGBBAA`) pour corriger la couleur, ou laissez l’invite vide pour suivre à nouveau l’accent. La couleur est lue lorsque la configuration Hyprland se charge, donc après un changement de thème ou d’accent, elle prend le nouvel accent au prochain rechargement de configuration.

Comme Blur, la page édite un brouillon : rien n’est écrit tant que **[ Appliquer ]** n’est pas sélectionné, et quitter la page avec un brouillon non appliqué demande une confirmation.

## État canonique et fichiers de compatibilité

La préférence logique est stockée dans `$XDG_CONFIG_HOME/argvus/config.json`. L'animation globale utilise `effects.animations` ; les valeurs d'Animations utilisent les clés `effects.animation_*` décrites ci-dessus. L'interrupteur global de Flou est `effects.blur_global_enabled`, et les valeurs de Flou utilisent les clés `effects.blur_*` listées ci-dessus. Les états d'activation des surfaces et les valeurs de transparence utilisent des clés telles que `effects.blur_control-center_enabled` et `effects.transparency_control-center_value`. Les valeurs de transparence sont limitées à `0–100` ; chaque valeur de Flou est limitée à sa propre plage, et `argvus-config` rejette les écritures en dehors de celle-ci. Les états d'activation restent distincts des remplacements manquants.

L'ancien pourcentage `effects.blur_global_value` n'est plus lu. Un profil qui le contient encore garde la clé sur le disque sans effet, et le Flou utilise les valeurs par défaut ci-dessus jusqu'à ce que ses valeurs soient appliquées.

```text
$XDG_CONFIG_HOME/argvus/config.json
```
`data/generated/effects/<active-theme>.conf` est la projection des effets, écrite uniquement par `argvus config` ; `argvus effects-toggle` délègue à `argvus config effects`. Un changement de thème ou de mode réapplique le profil visuel exporté du thème actif, y compris les valeurs par surface de `effects.conf` lorsqu'elles sont présentes. Les thèmes sans profil restaurent les valeurs par défaut des effets inclus. Exportez le thème après avoir modifié les effets si vous voulez que ces valeurs survivent à un autre changement de thème ou de mode.

La désactivation de l'interrupteur de Transparence ou de Flou d'une surface n'affecte que cette surface ; les valeurs numériques enregistrées sont conservées pour une réactivation ultérieure.

## Profils

L'exportation d'un thème inclut les paramètres canoniques d'apparence/effets et la projection des effets par surface du thème actif. Les fichiers d'exécution générés pour Waybar, Quickshell et Hyprland sont régénérés lorsque le thème est appliqué.

Toutes les pages de surface appliquent leurs brouillons avec le bouton `[ Apply ]`. Le Centre de Contrôle écrit le document canonique via l’assistant des effets, permet à `argvus-config` de projeter l’arbre des effets, recharge les consommateurs affectés et relit la valeur effective. Les fichiers générés sont recréés plutôt qu’importés comme état autoritaire.

## Lumière nocturne

**SUPER + Shift + B** conserve le sélecteur de luminosité et ajoute un interrupteur de Lumière nocturne séparé avec état/température effectif. Il appelle `argvus config display night-light status|toggle`. La Lumière nocturne nécessite Hyprland et un Hyprsunset répondant >= 0.4.0, indépendamment de la prise en charge de la luminosité. La plage est de 1000 à 20000 K ; la configuration se trouve sous **Bureau & Entrée > Écrans > Lumière nocturne** dans le Centre de Contrôle. Un interrupteur est persistant sans programmation, ou un dépassement volatil jusqu’à la prochaine transition avec programmation. Annuler le menu ne change rien.
