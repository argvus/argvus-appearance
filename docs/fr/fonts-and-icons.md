---
title: Polices et icônes
description: Configurez les polices et les thèmes d'icônes utilisés par ARGVUS.
---
`argvus-fonts` installe les polices incluses sous `/usr/share/fonts/` ; `argvus-icons` installe les thèmes d'icônes ARGVUS. `argvus-appearance` et le Centre de contrôle relient ces éléments au thème du bureau.

## Police principale

La police principale par défaut d'ARGVUS est **IBM Plex Mono**, avec le style `Regular`. C'est la famille par défaut utilisée par les cibles de police exposées dans le Centre de contrôle. Le package inclus `argvus-fonts` fournit IBM Plex Mono et les familles d'icônes/terminaux associées utilisées par le bureau.

Ouvrez **Centre de contrôle → Polices** pour configurer les cibles individuelles :

- barre des tâches ;
- télémétrie/informations système ;
- Panneau de configuration ;
- interface système ARGVUS ;
- applications ;
- terminal ;
- navigateur.

Les tailles par défaut sont spécifiques à chaque cible : barre des tâches, système et terminal utilisent `13` ; télémétrie et Panneau de configuration utilisent `14` ; applications utilisent `12` ; et navigateur utilise `10`. Ces valeurs par défaut peuvent être restaurées depuis la page Polices.

## Thème d'icônes

Le thème d'icônes actif est stocké canoniquement sous `appearance.icon_theme` dans `config.json`. Une valeur vide (la valeur par défaut) sélectionne le thème d'icônes ARGVUS du mode du thème actif : `Argvus Dark Icons` pour les thèmes sombres et `Argvus Light Icons` pour les thèmes clairs, tous deux installés par `argvus-icons`.

`sh/icon-switch.sh` résout le thème effectif et l'applique à chaque consommateur :

- Paramètres GNOME : `org.gnome.desktop.interface icon-theme` ;
- GTK 3 et GTK 4 : `gtk-icon-theme-name` dans les fichiers ARGVUS et natifs `settings.ini` ;
- Qt : `icon_theme` dans le `qt6ct.conf` géré, et dans le `qt6ct.conf` natif lorsqu'il a été généré par ARGVUS.

Les thèmes sont consultés dans `/usr/share/icons`, `$XDG_DATA_HOME/icons` et `~/.icons`. Un thème configuré qui n'est pas installé, ou une valeur qui contient `/` ou est `..`, revient au mode par défaut correspondant et enregistre un message, de sorte que le bureau ne pointe jamais vers un thème manquant. Un changement de thème ou de mode utilise le choix d'icône du profil de thème exporté lorsqu'il est présent, sinon il restaure le mode par défaut inclus dans le package. Exportez le thème pour conserver un choix d'icône personnalisé lors des changements.

Utilisez les contrôles de police dans le Centre de Contrôle. Les préférences de police sont canoniques dans `config.json`, à `fonts.targets.<target>` pour la famille, le style et la taille ainsi que `fonts.rendering` pour l'antialiasing, le hinting, l'ordre des sous-pixels et le DPI. Le Centre de Contrôle les conserve via `argvus-config` ; il n'écrit pas lui-même de fichiers utilisateur. `argvus-config` projette ensuite `data/generated/fonts.conf` et réécrit le bloc de police délimité à l'intérieur de `data/waybar/argvus-taskbar.css` et `data/waybar/argvus-widget-telemetry.css`, de sorte que les modifications de police en dehors de ces blocs survivent à un changement de police. Les règles de fontconfig de Terminal et GTK restent des cibles d'adaptateur natives. Le package exécute la mise à jour du cache de police pendant l'installation.

La génération du module de barre des tâches valide le JSONC résultant avant de le publier. Les listes de modules utilitaires sont reconstruites à partir des préférences activées, y compris un expandeur de tiroir uniquement en mode survol. Le mode icône de l’espace de travail rend `{windows}` aux côtés de `{name}`. La visibilité de la zone de notification n’affecte que les icônes des applications en arrière-plan.

Le projecteur du groupe utilitaire conserve custom/ai lorsqu’il est activé dans les modules optionnels et défini par le modèle de la barre des tâches. Son glyphe nf-md-robot (U+F06A9) ouvre le menu des agents AI partagés ; la disponibilité reste contrôlée par le module, même lorsque toutes les autres icônes utilitaires sont désactivées.

La visibilité de l’icône AI est contrôlée par /taskbar/icons/ai_agents_enabled (true par défaut), accessible via Centre de Contrôle > Apparence > Barre des tâches > Icônes > Modules optionnels > Agents AI. Le projecteur respecte l’état désactivé à chaque application et conserve le groupe utilitaire lorsque seuls les Agents AI sont activés.

Le projecteur de la barre des tâches place l'état de la mise à jour dans un groupe séparé entre les utilitaires et le groupe réseau/performance lorsque `/taskbar/icons/update_status_enabled` est vrai. Il met également à jour les configurations générées plus anciennes avec la définition du module.

L'assistant est `argvus window-mode-menu` ; `argvus window-mode-menu --status` émet du JSON Waybar. Il est fourni par le package principal `argvus`. Les copies personnalisées existantes de la barre des tâches sont préservées : ajoutez la définition de module `custom/window-mode` et l'entrée de groupe à partir du modèle empaqueté pour participer, ou utilisez le Centre de contrôle. Le projecteur d'apparence conserve le module lorsque sa définition est présente, même si d'autres icônes d'utilitaires sont désactivées.

Les consommateurs de thèmes `window-bar` et `window-controls` dérivent leurs couleurs de bg, fg et accent. Les couleurs de la barre de titre se rechargent via `argvus windows decorations` ; la barre de fenêtre observe sa feuille de style générée. Tile/Floating est indépendant de la géométrie d'apparence Sticky/Spaced.
