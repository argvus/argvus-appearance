---
title: Schriftarten und Symbole
description: Konfigurieren Sie die Schriftarten und Symbolthemen, die von ARGVUS verwendet werden.
---
`argvus-fonts` installiert die mitgelieferten Schriftarten unter `/usr/share/fonts/`; `argvus-icons` installiert die ARGVUS-Symbolthemen. `argvus-appearance` und das Kontrollzentrum verbinden diese Assets mit dem Desktop-Thema.

## Primäre Schriftart

Die standardmäßige primäre Schriftart von ARGVUS ist **IBM Plex Mono**, mit dem `Regular`-Stil. Es ist die standardmäßige Familie, die von den im Kontrollzentrum verfügbaren Schriftzielen verwendet wird. Das mitgelieferte `argvus-fonts`-Paket stellt IBM Plex Mono und die unterstützenden Symbol-/Terminal-Familien bereit, die vom Desktop verwendet werden.

Öffnen Sie **Kontrollzentrum → Schriftarten**, um einzelne Ziele zu konfigurieren:

- Taskleiste;
- Telemetrie/Systeminformationen;
- Systemsteuerung;
- ARGVUS-Systemoberfläche;
- Anwendungen;
- Terminal;
- Browser.

Die Standardgrößen sind zielabhängig: Taskleiste, System und Terminal verwenden `13`; Telemetrie und Systemsteuerung verwenden `14`; Anwendungen verwenden `12`; und Browser verwenden `10`. Diese Standardwerte können auf der Seite Schriftarten wiederhergestellt werden.

## Symbolthema

Das aktive Symbolthema wird kanonisch als `appearance.icon_theme` in `config.json` gespeichert. Ein leerer Wert (Standard) wählt das ARGVUS-Symbolthema des Modus des aktiven Themas: `Argvus Dark Icons` für dunkle Themen und `Argvus Light Icons` für helle Themen, beide installiert von `argvus-icons`.

`sh/icon-switch.sh` ermittelt das effektive Thema und wendet es auf jeden Verbraucher an:

- GNOME-Einstellungen: `org.gnome.desktop.interface icon-theme`;
- GTK 3 und GTK 4: `gtk-icon-theme-name` in den ARGVUS- und nativen `settings.ini`-Dateien;
- Qt: `icon_theme` in der verwalteten `qt6ct.conf` und in der nativen `qt6ct.conf`, wenn sie von ARGVUS generiert wurde.

Themen werden in `/usr/share/icons`, `$XDG_DATA_HOME/icons` und `~/.icons` nachgeschlagen. Ein konfiguriertes Thema, das nicht installiert ist, oder ein Wert, der `/` enthält oder `..` ist, fällt auf den gleichen Standardmodus zurück und protokolliert eine Meldung, sodass der Desktop niemals auf ein fehlendes Thema verweist. Ein Themen- oder Moduswechsel verwendet die Symbolwahl des exportierten Themenprofils, wenn vorhanden, andernfalls wird der im Paket enthaltene Standardmodus wiederhergestellt. Exportieren Sie das Thema, um eine benutzerdefinierte Symbolwahl über Wechsel hinweg zu erhalten.

Verwenden Sie die Schriftarten-Steuerelemente im Kontrollzentrum. Schriftarten-Einstellungen sind kanonisch in `config.json`, bei `fonts.targets.<target>` für Familie, Stil und Größe sowie `fonts.rendering` für Kantenglättung, Hinting, Subpixelreihenfolge und DPI. Das Kontrollzentrum speichert diese durch `argvus-config`; es schreibt selbst keine Benutzerdaten. `argvus-config` projiziert dann `data/generated/fonts.conf` und schreibt den abgegrenzten Schriftblock innerhalb von `data/waybar/argvus-taskbar.css` und `data/waybar/argvus-widget-telemetry.css` neu, sodass Schriftbearbeitungen außerhalb dieser Blöcke eine Schriftartänderung überleben. Terminal- und GTK-Schriftartkonfigurationsregeln bleiben native Adapter-Ziele. Das Paket führt während der Installation das Aktualisieren des Schriftcaches durch.

Die Taskleistenmodul-Generierung validiert das resultierende JSONC, bevor es veröffentlicht wird. Die Listen des Utility-Moduls werden aus den aktivierten Einstellungen neu aufgebaut, einschließlich eines Drawer-Expanders nur im Hover-Modus. Der Arbeitsbereichs-Icon-Modus rendert `{windows}` neben `{name}`. Die Sichtbarkeit des System-Trays betrifft nur Hintergrundanwendungs-Icons.

Der Utility-Gruppen-Projektor bewahrt Custom/AI, wenn er in den Optionalen Modulen aktiviert ist und durch die Taskleisten-Vorlage definiert wird. Sein nf-md-robot-Symbol (U+F06A9) öffnet das Menü der gemeinsamen KI-Agenten; die Verfügbarkeit wird weiterhin durch das Modul gesteuert, auch wenn alle anderen Utility-Icons deaktiviert sind.

Die Sichtbarkeit des KI-Icons wird durch /taskbar/icons/ai_agents_enabled (Standard true) gesteuert und ist unter Kontrollzentrum > Darstellung > Taskleiste > Icons > Optionale Module > KI-Agenten zugänglich. Der Projektor berücksichtigt den deaktivierten Zustand bei jeder Anwendung und behält die Utility-Gruppe bei, wenn nur KI-Agenten aktiviert sind.

Der Taskleisten-Projektor platziert den Update-Status in einer separaten Gruppe zwischen Dienstprogramme und der Netzwerk-/Leistungsgruppe, wenn `/taskbar/icons/update_status_enabled` true ist. Er aktualisiert außerdem ältere generierte Konfigurationen mit der Moduldefinition.

Der Helfer ist `argvus window-mode-menu`; `argvus window-mode-menu --status` gibt Waybar JSON aus. Er wird vom Master-Paket `argvus` bereitgestellt. Bestehende angepasste Taskleistenkopien bleiben erhalten: Fügen Sie die `custom/window-mode`-Moduldefinition und den Gruppeneintrag aus der bereitgestellten Vorlage hinzu, um teilzunehmen, oder verwenden Sie das Kontrollzentrum. Der Erscheinungsprojektor behält das Modul bei, wenn seine Definition vorhanden ist, selbst wenn andere Dienstprogrammsymbole deaktiviert sind.

Die `window-bar`- und `window-controls`-Themenkonsumenten leiten ihre Farben von bg, fg und Akzent ab. Die Farben der Titelleiste werden über `argvus windows decorations` neu geladen; die Fensterleiste beachtet ihr generiertes Stylesheet. Kachel/Schweben ist unabhängig von Sticky/Spacing-Aussehensgeometrie.
