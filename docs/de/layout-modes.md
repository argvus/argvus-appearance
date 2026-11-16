---
title: Layout-Modi
description: Wählen Sie das Sticky- oder Spaced-Desktop-Layout.
---
Sticky hält Fenster- und Shell-Oberflächen kompakt. Spaced verwendet größere Abstände, abgerundete Ecken und breitere Taskleistenränder. Der Layout-Modus ist unabhängig vom gewählten Thema; ein Wechsel der Modi wendet die Geometrie dieses Modus erneut an.

Wählen Sie den Modus in **Systemsteuerung → Erscheinungsbild → Desktop → Erscheinungsbildmodus** oder öffnen Sie seinen Auswahlpicker mit `SUPER + Shift + M`. Die kanonische Einstellung ist `/layout/variant`, mit den Werten `sticky` und `spaced`. Aufgelöste Spaced-Themen-IDs verwenden das Suffix `-spaced`. Bestehende `float`-Werte und `-float`-IDs bleiben für die Kompatibilität lesbar.

`argvus layout-mode-menu` (SUPER + Shift + M): **Tab / Shift+Tab**: Sticky/Spaced ⇄ Tile/Floating · Taskbar Top/Bottom. Wählen Sie Sticky oder Spaced mit ↑/↓. Die vier Karten rechts kombinieren gekachelte oder schwebende Fenster mit der Taskleiste oben oder unten; ↑/↓/←/→ durchläuft sie ohne Schleife. Klicken zum Auswählen, Enter zum Anwenden, Escape zum Abbrechen. Der nicht ausgewählte Modus ist abgedunkelt; die Vorschauen verwenden das aktuelle Theme und Hintergrundbild. Ausstehende Anwendungen bleiben sichtbar, Fehler erlauben einen erneuten Versuch.

Die Auswahlfenster zeigen den Fortschritt ohne Ladebildschirm der Sitzung. Moduswechsel bereiten die endgültige Taskleistenposition vor dem Neuladen vor; notwendige Neustarts werden in einer systemd-Transaktion gebündelt.
