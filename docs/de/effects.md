---
title: Effekte
description: Konfigurieren Sie Animationen, die globale Hyprland-Unschärfe und die Transparenz pro Oberfläche.
---
**Kontrollzentrum → Hyprland** enthält **Animationen**, **Unscharf** und **Rahmen**, deren **Schatten**-Seite den Fensterschatten steuert. Transparenz-Enable-Schalter sind pro Oberfläche in den jeweiligen Erscheinungsbild-Seiten eingestellt.

Oberflächen-Schalter sind unabhängig. Die Konfigurationsseite des Kontrollzentrums hat ihren eigenen Transparenzwert und Unscharf-Enable-Schalter; ihr Unscharf verwendet die globalen Unscharf-Werte.

Das Kontrollzentrum wird über Foot mit einem dedizierten, generierten Profil bei `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini` gestartet. Mit Foot 1.28 wird die Transparenz auf `[colors-dark] alpha` projiziert und der Oberflächen-Unscharf-Schalter auf `[colors-dark] blur`; die normale Foot-Konfiguration und das ARGVUS-Terminal bleiben unabhängig.

## Animationen- und Effekte-Schalter

Es gibt zwei unabhängige Hauptschalter, die beide auf `hyprland.lua` über die kanonischen `/effects`-Einstellungen angewendet werden:

- **Animationen** (`/effects/animations`) steuern alles, was sich bewegt: Arbeitsbereich, Fenster, Ein- und Ausblenden, Rahmen- und Ebenenanimationen.
- **Effekte** ist eine Abkürzung für Unschärfe (`/effects/blur_global_enabled`) und die Transparenz von Terminal, Launcher, Widget Telemetrie, Systemsteuerung und Taskleiste (`/effects/transparency_<surface>_enabled`). Das Ein- oder Ausschalten schreibt alle diese Werte (und auch die Transparenz des Kontrollzentrums). Jede Oberfläche behält ihre eigene Transparenzseite, sodass Effekte als **ein** gelesen werden, wenn mindestens eines von ihnen aktiviert ist, und nur als ausgeschaltet, wenn alle deaktiviert sind.

Verwenden Sie `argvus effects-toggle animations status|enable|disable|toggle` und `argvus effects-toggle effects status|enable|disable|toggle`. Die Karte „Erscheinungsbild der Systemsteuerung“ zeigt für jeden einen Schalter. Das Ausschalten eines Hauptschalters behält jede Feineinstellung der **Animationen**- und **Blur**-Seiten (Geschwindigkeiten, Kurven, pro-Blatt-Schalter, Unschärfengröße und Durchläufe) bei, sodass das erneute Einschalten denselben Look wiederherstellt. `effects status` druckt `enabled`, wenn Unschärfe oder mindestens eine dieser Transparenzflächen aktiviert ist. Das Ausschalten der Transparenz einer Fläche macht die gesamte Waybar-Oberfläche undurchsichtig: Neben dem Hintergrund werden die halbtransparenten Ränder der Taskleiste und der Widget-Telemetrie zur festen Farbe, die sie über dem Thema-Hintergrund anzeigen. Jeder Effekt ist standardmäßig bei einer Neuinstallation aktiviert, auch in virtuellen Maschinen und Energiesparmodi; nur eine explizite Einstellung schaltet einen Effekt aus.

## Alle Effekte gleichzeitig

`argvus effects-toggle` ohne eine Komponente wirkt gleichzeitig auf Animationen, Unschärfe und Transparenz: `status` druckt `enabled` nur, wenn alle drei aktiviert sind, `enable` und `disable` schalten alle drei um, und `toggle` schaltet alles aus, wenn `status` `enabled` ist, und ansonsten ein. **SUPER + F6** führt diesen Umschalter aus. Um auf eine einzelne Gruppe zu wirken, benennen Sie sie: `argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`. Die **Animations**-Seite des Kontrollzentrums verwendet die pro-Komponente-Form, sodass ihr **Aktivieren**-Schalter weiterhin nur Animationen ändert.

## Transparenz

Jede Oberfläche hat ihr eigenes **Transparenz**-Untermenü mit einem Aktivierungsschalter und einem Wert.

Die Seite **Aussehen → Startprogramme** steuert den offiziellen auf Rofi basierenden Launcher- und Picker-Flow: den Hauptlauncher, Emoji-Picker, Taschenrechner, Zwischenablage-Picker, Cheatsheets und Rofi-Menüs für abnehmbare Geräte. Sein Transparenzwert ist der endgültige Hintergrund-Alpha, sodass `50` eine effektive Hintergrunddeckkraft von ungefähr `0.50` bedeutet; Text, Symbole und ausgewählte Zeilen bleiben undurchsichtig. Mit ausgeschalteter Transparenz verwendet der Launcher die Hintergrundfarbe des aktiven Themas, vollständig undurchsichtig. Der Blur-Schalter legt die `rofi`-Ebene in die globalen Blur-Einstellungen.

Jeder Wert reicht von `0%` (undurchsichtig) bis `100%` (vollständig transparent). Verwenden Sie `+` und `-` in 5%-Schritten und wählen Sie dann **Anwenden** auf der Oberfläche-Seite. Das Verlassen der Seite verwirft einen nicht angewendeten Entwurf.

Verwenden Sie `↑` und `↓`, um zwischen **Aktivieren** und **Wert** zu wechseln. In der **Wert**-Zeile passen `+` und `-` den Entwurf an, ohne den Fokus zu ändern. Drücken Sie `Tab`, um **Aktionen** zu öffnen, und aktivieren Sie dann **[ Anwenden ]**; `Esc` kehrt zur übergeordneten Oberflächenseite zurück.

## Animationen

Öffnen Sie **Kontrollzentrum → Hyprland → Animationen**. Die Seite hat einen **Aktivieren**-Schalter und eine **Optionen**-Liste mit **Benutzerdefinierten Kurven** und fünf Kategorien. Jede Kategorie enthält ihre Animationen, und jede Animation hat eine eigene Seite mit **Stil**, **Geschwindigkeit**, **Kurve** und, für Fensteröffnungen und -schließungen, **Pop-in-Prozentsatz**. Animationen, die Hyprland deaktivieren kann, haben ebenfalls eine **Aktivieren**-Zeile.

Jeder Wert auf diesen Seiten gehört zu einem Entwurf, der vom gesamten Animationsbaum geteilt wird. Nichts wird geschrieben, bis **[ Anwenden ]** unten auf einer der Seiten ausgewählt wird. Das Wechseln zwischen den Seiten behält den Entwurf; das Verlassen der Animationsseite mit einem nicht angewendeten Entwurf fordert eine Bestätigung an. Anwenden schreibt die geänderten Werte in einem Schritt und lädt Hyprland neu. Der **Aktivieren**-Schalter oben ist der globale Animationszustand (`effects.animations`): Wenn er ausgeschaltet ist, ist jede Animation deaktiviert, egal was ihr eigener Schalter sagt.

Steuerung: `↑/↓` bewegt sich zwischen den Zeilen; `←/→` (oder `+/-`) ändert den ausgewählten Wert und wechselt **Stil** und **Kurve**; `Enter` gibt eine genaue **Geschwindigkeit**, **Pop-in-Prozentsatz** oder Kurvenparameter ein (außerhalb des Bereichs liegende Werte werden abgelehnt) und wechselt **Stil** und **Kurve** vorwärts.

### Kategorien und Animationen

| Kategorie | Animation | Schlüssel (`effects.animation_<key>_*`) | Stil (Standard) | Geschwindigkeit | Aktivieren |
|---|---|---|---|---|---|
| Windows | Öffnen von Fenstern | `opening` | `popin`, Pop-in 87 % | 4.1 | — |
| Windows | Schließen von Fenstern | `closing` | `popin`, Pop-in 87 % | 1,49 | — |
| Windows | Fenster verschieben | `moving` | — | 4,79 | ja |
| Arbeitsbereiche | Arbeitsbereich wechseln | `switching` | `fade` | 1,94 | — |
| Arbeitsbereiche | Eingang zum Arbeitsbereich | `workspace_in` | `fade` | 1,21 | — |
| Arbeitsbereiche | Arbeitsbereich verlassen | `workspace_out` | `fade` | 1,94 | — |
| Arbeitsbereiche | Spezielle Arbeitsbereiche | `special_workspace` | `slide` | 5 | — |
| Ebenen und Popups | Schichtoberflächen | `layers` | — | 3,81 | ja |
| Ebenen und Popups | Ebeneneingang | `layers_in` | `fade` | 4 | — |
| Ebenen und Popups | Ebenenausgang | `layers_out` | `fade` | 1,5 | — |
| Ebenen und Popups | Verblassen | `fade` | — | 3.03 | ja |
| Ebenen und Popups | Einblenden | `fade_in` | — | 1,73 | ja |
| Ebenen und Popups | Ausblenden | `fade_out` | — | 1,46 | ja |
| Grenzen & Effekte | Randfarbe | `border` | — | 5,39 | ja |
| Ränder & Effekte | Rand-Gradientenwinkel | `border_angle` | — | 5 | ja |
| Andere Animationen | Zoomfaktor | `zoom` | — | 7 | ja |
| Andere Animationen | Monitor hinzugefügt | `monitor_added` | — | 5 | ja |

Die Standardwerte der Blätter, die Hyprland 0.56.2 in seiner Standardkonfiguration ausliefert (jede Zeile außer Spezielle Arbeitsbereiche, Rand-Gradientenwinkel und Monitor hinzugefügt), sind die Standardgeschwindigkeiten, -stile und -kurven. Diese drei behalten die ARGVUS-Standards bei, weil die Standardkonfiguration sie nicht definiert.

Jedes Blatt bietet nur die Stile, die Hyprland 0.56.2 dafür akzeptiert. Das Öffnen und Schließen von Fenstern bietet `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` und `gnomed`. Das Betreten und Verlassen von Ebenen bietet `slide`, `popin`, `fade`, `slidefade`, `slidevert` und `slidefadevert`. Arbeitsbereichsblätter (Wechseln, Betreten, Verlassen und spezielle Arbeitsbereiche) bieten `slide`, `fade`, `slidefade`, `slidevert` und `slidefadevert`, ohne `popin` oder `gnomed`. Ein gespeicherter Stil außerhalb der Liste seines Blattes wird ignoriert und das Blatt verwendet seinen Standardstil. Jede Animation beginnt mit der `default`-Kurve. Eine Seite bietet nur die Reihen, die ihre Animation unterstützt. Die gespeicherten Tasten sind `effects.animation_<key>_speed`, `_curve`, `_style` (wo angeboten), `_popin` (Fensteröffnen und -schließen) und `_enabled` (wo angeboten).

### Kurven

| Kurve | Verhalten | Parameter (Schlüssel → Standard) |
|---|---|---|
| `default` | Die Kurve, die Hyprland 0.56.2 für diese Animation bereitstellt (zum Beispiel `easeOutQuint`, `almostLinear`, `quick`, `linear` oder die `easy`-Feder). Animationen ohne Standardkurve verwenden ARGVUS' eingebaute Bézier-Kurve. | Fest |
| `bezier` | Flüssige Bewegung, die beschleunigt und abbremst, geformt durch zwei Kontrollpunkte. | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Physikalische Bewegung mit Masse, Steifigkeit und Dämpfung; sie kann für einen elastischen Effekt überschießen. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | Konstante Geschwindigkeit für die gesamte Animation, von `(0, 0)` bis `(1, 1)`. | Fest |
| `ease_out` | Schnell am Anfang und sanft am Ende, von `(0, 0)` bis `(0.58, 1)`. | Fest |

Unter **Benutzerdefinierte Kurven** hat jede Kurve ihre eigene Seite. Bézier bearbeitet seine vier Kontrollpunkte, Spring bearbeitet Masse, Steifigkeit und Dämpfung, und Linear und Ease-out zeigen ihre festen Punkte an. Die Bézier- und Spring-Werte gelten für jede Animation, die diese Kurve auswählt.

Bereiche und Schritte: **Geschwindigkeit** 1–10 mit Dezimalstellen (Schritt 0,1, die Standardgeschwindigkeiten sind dezimal); **Pop-in-Prozentsatz** 1–100 in ganzen Zahlen (Schritt 5, Standard 87); Bézier-Punkte wie oben (Schritt 0,05); Spring-Masse 0,5–10 (Schritt 0,1), Steifigkeit 0,5–2000 (Schritt 10) und Dämpfung 0,5–200 (Schritt 1).

Nicht angeboten: Hyprland 0.56.2 hat keine separate Animation für das Größenänderung von Fenstern, für Popups oder für die Schatten- und Leuchtverlaufswinkel, daher zeigt die Seite keine Zeilen für sie an.

## Unschärfe

Blur ist eine globale Hyprland-Einstellung, die von jeder Oberfläche geteilt wird, die sich dafür entscheidet. Öffne **Systemsteuerung → Hyprland → Blur**. Die Seite hat einen **Aktivieren**-Schalter und eine **Werte**-Liste mit den Parametern von Hyprlands `decoration:blur`, unter den Namen, die Hyprland verwendet:

| Zeile | Konfigurationsschlüssel | Standard | Bereich | `←/→` Schritt |
|---|---|---|---|---|
| Größe | `effects.blur_size` | `6` | 1–64 | 1 |
| Durchläufe | `effects.blur_passes` | `2` | 1–8 | 1 |
| Helligkeit | `effects.blur_brightness` | `1` | 0–2 | 0.05 |
| Rauschen | `effects.blur_noise` | `0.00` | 0–1 | 0.01 |
| Kontrast | `effects.blur_contrast` | `0.900000` | 0–2 | 0.05 |
| Lebendigkeit | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0.01 |
| Lebendigkeit Dunkelheit | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0.01 |

Verwende `↑/↓`, um zu bewegen, `←/→` (oder `+/-`), um den ausgewählten Wert um seinen Schritt zu ändern, und `Enter`, um einen genauen Wert einzugeben; Werte außerhalb des Bereichs werden abgelehnt. Es wird nichts geschrieben, während du bearbeitest: der Schalter und die Werte bleiben im Entwurf, bis **[ Anwenden ]** unten auf der Seite ausgewählt wird. Anwenden schreibt jeden geänderten Wert in einem Aufruf und lädt Hyprland danach neu. Das Verlassen der Seite mit einem nicht angewendeten Entwurf erfordert eine Bestätigung.

Werte werden unverändert an Hyprland übergeben; ARGVUS leitet sie nicht aus einem Prozentsatz ab. Das Ändern des Schalters einer Oberfläche ändert die Werte nicht.

## Schatten

Der Fensterschatten ist eine globale Einstellung in Hyprland unter **Control Center → Hyprland → Borders → Shadow**. Er ist unabhängig von Transparenz und Unschärfe: standardmäßig ist er ausgeschaltet, und das Ein- oder Ausschalten der Transparenz einer Oberfläche ändert ihn nicht.

| Zeile | Konfigurationsschlüssel | Standard | Bereich | `←/→` Schritt |
|---|---|---|---|---|
| Aktivieren | `effects.shadow_enabled` | `false` | — | — |
| Scharf | `effects.shadow_sharp` | `false` | — | — |
| Farbe | `effects.shadow_color` | leer (folgt dem Akzent) | leer oder `RRGGBBAA` | — |
| Bereich | `effects.shadow_range` | `6` | 0–100 | 1 |
| Renderleistung | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| Versatz X | `effects.shadow_offset_x` | `0` | −100 bis 100 | 1 |
| Versatz Y | `effects.shadow_offset_y` | `0` | −100 bis 100 | 1 |
| Skalierung | `effects.shadow_scale` | `1.00` | 0–1 | 0,05 |

Eine leere Farbe folgt dem Akzent des aktiven Themas mit Alpha `99`, sodass der standardmäßige blaue Akzent `3590bd99` ergibt. Geben Sie acht Hexadezimalstellen ein (`RRGGBBAA`), um die Farbe festzulegen, oder lassen Sie das Feld leer, um wieder dem Akzent zu folgen. Die Farbe wird beim Laden der Hyprland-Konfiguration gelesen, sodass nach einer Änderung des Themas oder Akzents beim nächsten Konfigurations-Neuladen der neue Akzent übernommen wird.

Wie bei Blur bearbeitet die Seite einen Entwurf: Es wird nichts geschrieben, bis **[ Anwenden ]** ausgewählt wird, und beim Verlassen der Seite mit einem nicht angewendeten Entwurf wird um Bestätigung gebeten.

## Kanonischer Zustand und Kompatibilitätsdateien

Die logische Präferenz wird in `$XDG_CONFIG_HOME/argvus/config.json` gespeichert. Globale Animation verwendet `effects.animations`; die Animationswerte verwenden die oben beschriebenen `effects.animation_*`-Schlüssel. Der globale Blur-Schalter ist `effects.blur_global_enabled`, und die Blur-Werte verwenden die oben aufgeführten `effects.blur_*`-Schlüssel. Die Aktivierungszustände der Oberfläche und Transparenzwerte verwenden Schlüssel wie `effects.blur_control-center_enabled` und `effects.transparency_control-center_value`. Transparenzwerte sind auf `0–100` begrenzt; jeder Blur-Wert ist auf seinen eigenen Bereich begrenzt, und `argvus-config` lehnt Schreibzugriffe außerhalb dieses Bereichs ab. Aktivierungszustände bleiben von fehlenden Überschreibungen getrennt.

Der frühere `effects.blur_global_value`-Prozentsatz wird nicht mehr gelesen. Ein Profil, das diesen noch enthält, behält den Schlüssel auf der Festplatte ohne Wirkung, und Blur verwendet die oben genannten Standardwerte, bis seine Werte angewendet werden.

```text
$XDG_CONFIG_HOME/argvus/config.json
```
`data/generated/effects/<active-theme>.conf` ist die Effektprojektion, die nur von `argvus config` geschrieben wird; `argvus effects-toggle` Delegierte an `argvus config effects`. Ein Theme- oder Moduswechsel wendet das exportierte visuelle Profil des aktiven Themes erneut an, einschließlich der Werte pro Oberfläche aus `effects.conf`, wenn vorhanden. Themes ohne Profil stellen verpackte Effekt-Standardeinstellungen wieder her. Exportiere das Theme nach der Änderung der Effekte, wenn du möchtest, dass diese Werte ein anderes Thema oder einen anderen Moduswechsel überleben. 

Das Deaktivieren des Transparenz- oder Unschärfeschalters einer Oberfläche wirkt sich nur auf diese Oberfläche aus; gespeicherte Zahlenwerte werden für spätere Wiederaktivierung beibehalten. 

## Profile

Der Theme-Export umfasst kanonische Erscheinungs-/Effekteinstellungen sowie die pro-Oberfläche-Effektprojektion des aktiven Themas. Generierte Waybar-, Quickshell- und Hyprland-Laufzeitdateien werden beim Auftragen des Themas neu generiert.

Alle Oberflächenseiten wenden ihre Entwürfe zusammen mit der `[ Apply ]`-Taste an. Das Kontrollzentrum schreibt das kanonische Dokument über den Effekte-Helfer, lässt `argvus-config` den Effektbaum projizieren, lädt betroffene Verbraucher neu und liest den effektiven Wert zurück. Generierte Dateien werden neu erstellt, anstatt als maßgeblicher Zustand importiert zu werden.

## Nachtlicht

**SUPER + Shift + B** behält den Helligkeitsregler bei und fügt einen separaten Nachtlicht-Umschalter mit effektivem Zustand/Temperatur hinzu. Es ruft `argvus config display night-light status|toggle` auf. Nachtlicht erfordert Hyprland und ein reagierendes Hyprsunset >= 0.4.0, unabhängig von der Helligkeitsunterstützung. Der Bereich liegt bei 1000–20000 K; die Konfiguration befindet sich unter **Desktop & Eingabe > Anzeigen > Nachtlicht** im Kontrollzentrum. Ein Umschalter ist persistent ohne Zeitplan oder ein flüchtiger Überschreibungswert bis zur nächsten Übergangszeit mit Zeitplan. Das Abbrechen des Menüs ändert nichts.
