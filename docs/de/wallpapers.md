---
title: Hintergründe
description: Verwenden Sie integrierte und benutzerdefinierte ARGVUS-Hintergrundbilder.
---
Die integrierten JPEG XL-Hintergrundbilder werden von `argvus-wallpapers` unter `/usr/share/backgrounds/argvus/` installiert. In **Kontrollzentrum → Erscheinungsbild → Hintergrundbilder** sind sie als `Abstract` oder `Landscape` organisiert, dann nach `Dark` oder `Light`. Die Stammdateien `argvus-dark.jxl` und `argvus-light.jxl` erscheinen unter den abstrakten Fallback-Gruppen. Der Themenwechsel verwendet nur die abstrakten Dateien in `abstract/dark` und `abstract/light`; Landschaftsdateien sind optionale manuelle Auswahlmöglichkeiten. Drücken Sie `SUPER + Y`, um diesen Bildschirm des Kontrollzentrums direkt zu öffnen. Der erste Eintrag akzeptiert auch ein benutzerdefiniertes Bild von HOME; die ausgewählte Datei wird zum benutzerdefinierten Hintergrundbild des Benutzers.

Der erste Eintrag öffnet einen Dateiauswahldialog für ein benutzerdefiniertes Bild. Ein ausgewähltes benutzerdefiniertes Hintergrundbild wird als `/appearance/wallpaper` zusammen mit `/appearance/wallpaper_custom` in der kanonischen Konfiguration gespeichert, und `argvus config` projiziert es in die Hyprland-Hintergrundbildkonfiguration, die von der Sitzung verwendet wird. Es bleibt aktiv, bis eine Themen- oder Modusänderung das Hintergrundbild dieses Themas erneut anwendet. Exportieren Sie das aktive Thema, um das aktuelle Hintergrundbild einzuschließen und es im exportierten Thema zu bewahren. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` ist nur ein Eingabefeld für die alte Migration.

Beim Export eines Themas wird das aktuelle Hintergrundbild eingeschlossen, wenn es lesbar ist. Beim Importieren wird das Thema installiert; das Anwenden aktiviert dessen Hintergrundbild. Siehe [Importieren und Exportieren von Themen](/docs/components/argvus-themes/import-and-export/).

Die benutzerseitigen Erscheinungskontrollen verwenden den Hyprland-Helfer `hypr-wallpaper-pick.sh`, der den gewählten Pfad über `argvus config` festschreibt, anstatt den Zustand des Hintergrundbildes selbst zu speichern. Bearbeiten Sie die generierte Hintergrundbildkonfiguration nicht direkt.
