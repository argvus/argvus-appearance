---
title: Visuelle Theme-Auswahl
---

Öffne `argvus theme-selector`, `argvus theme-switch` ohne Argumente oder `SUPER + Shift + T`. Das unabhängige GTK-Overlay zeigt auf dem aktiven Monitor eine große Vorschau mit benachbarten Karten. Suche oder filtere Alle/Dunkel/Hell; navigiere mit Pfeilen, Mausrad oder Seitenkarten. Eingabe oder Theme anwenden bestätigt; Escape oder Schließen bricht ab. Das Durchblättern verändert den Desktop nicht. System- und Benutzerthemes nutzen den vorhandenen Katalog. Ein gültiges `preview`-Bild hat Vorrang; sonst entsteht aus Hintergrundbild und Palette eine illustrative Vorschau ohne exakte Anwendungsanpassungen. Die bestehende Transaktion erhält Sticky/Spaced. Fehler erlauben einen neuen Versuch. JXL-Miniaturen benötigen `djxl` aus `libjxl`; der XDG-Cache enthält `argvus/theme-selector/v2`.

Beim Öffnen des Selektors liegt der anfängliche Fokus auf der Karussellnavigation. Mit `/` erhält oder verlässt die Suche den Fokus; bei fokussierter Suche filtert die Eingabe die Themes. **Benutzerdefiniert** zeigt vom Benutzer installierte Themes, **Dunkel** und **Hell** die Systemthemes der jeweiligen Kategorie. Die Suchzeile ist so breit wie die zentrale Vorschau. Sticky verwendet überall gerade Ecken, Spaced behält abgerundete Ecken. Die kompakte Monospace-Optik passt zu den ARGVUS-Desktopwerkzeugen.

Während der Anwendung wird die zentrale Vorschau abgedunkelt und zeigt einen Ladeindikator. Der Suchfokus verwendet die aktive Akzentfarbe; der Filter hat einen einzelnen Rahmen.
