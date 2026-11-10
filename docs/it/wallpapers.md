---
title: Sfondi
description: Usa sfondi ARGVUS integrati e personalizzati.
---
Gli sfondi JPEG XL integrati sono installati da `argvus-wallpapers` sotto `/usr/share/backgrounds/argvus/`. In **Centro di Controllo → Aspetto → Sfondi**, sono organizzati come `Abstract` o `Landscape`, poi per `Dark` o `Light`. I file principali `argvus-dark.jxl` e `argvus-light.jxl` appaiono sotto i gruppi di riserva astratti. Il cambio tema utilizza solo i file astratti in `abstract/dark` e `abstract/light`; i file paesaggio sono scelte manuali opzionali. Premi `SUPER + Y` per aprire direttamente questa schermata del Centro di Controllo. La prima voce accetta anche un'immagine personalizzata da HOME; il file selezionato diventa lo stato del wallpaper personalizzato dell'utente.

La prima voce apre un selettore di file per un'immagine personalizzata. Uno sfondo personalizzato selezionato viene memorizzato come `/appearance/wallpaper` insieme a `/appearance/wallpaper_custom` nella configurazione canonica, e `argvus config` lo proietta nella configurazione dello sfondo di Hyprland utilizzata dalla sessione. Rimane attivo fino a quando un cambiamento di tema o modalità non riapplica lo sfondo di quel tema. Esporta il tema attivo per includere l'attuale sfondo e conservarlo nel tema esportato. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` è solo un input di migrazione legacy.

Quando un tema viene esportato, l'immagine dello sfondo corrente viene inclusa quando è leggibile. L'importazione installa il tema; applicarlo attiva il suo sfondo. Vedi [Importing and exporting themes](/docs/components/argvus-themes/import-and-export/).

I controlli dell'aspetto destinati all'utente utilizzano l'aiutante di Hyprland `hypr-wallpaper-pick.sh`, che conferma il percorso scelto tramite `argvus config` invece di memorizzare direttamente lo stato dello sfondo. Non modificare direttamente la configurazione dello sfondo generata.
