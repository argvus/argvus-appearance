---
title: Caratteri e icone
description: Configura i font e i temi delle icone utilizzati da ARGVUS.
---
`argvus-fonts` installa i font inclusi sotto `/usr/share/fonts/`; `argvus-icons` installa i temi delle icone ARGVUS. `argvus-appearance` e il Centro di Controllo collegano questi asset al tema del desktop.

## Font principale

Il font principale predefinito di ARGVUS è **IBM Plex Mono**, con lo stile `Regular`. È la famiglia predefinita utilizzata dai target dei font esposti nel Centro di Controllo. Il pacchetto incluso `argvus-fonts` fornisce IBM Plex Mono e le famiglie di supporto per icone/terminale utilizzate dal desktop.

Apri **Centro di Controllo → Font** per configurare i singoli target:

- barra delle applicazioni;
- telemetria/informazioni di sistema;
- Pannello di Controllo;
- interfaccia di sistema ARGVUS;
- applicazioni;
- terminale;
- navigatore.

Le dimensioni predefinite sono specifiche per target: barra delle applicazioni, sistema e terminale utilizzano `13`; telemetria e Pannello di Controllo utilizzano `14`; applicazioni utilizzano `12`; e il browser utilizza `10`. Questi valori predefiniti possono essere ripristinati dalla pagina Font.

## Tema delle icone

Il tema delle icone attivo è memorizzato in modo canonico come `appearance.icon_theme` in `config.json`. Un valore vuoto (predefinito) seleziona il tema delle icone ARGVUS della modalità del tema attivo: `Argvus Dark Icons` per i temi scuri e `Argvus Light Icons` per i temi chiari, entrambi installati da `argvus-icons`.

`sh/icon-switch.sh` risolve il tema effettivo e lo applica a ogni consumatore:

- Impostazioni GNOME: `org.gnome.desktop.interface icon-theme`;
- GTK 3 e GTK 4: `gtk-icon-theme-name` nei file ARGVUS e nei file nativi `settings.ini`;
- Qt: `icon_theme` nel `qt6ct.conf` gestito, e nel `qt6ct.conf` nativo quando è stato generato da ARGVUS.

I temi vengono cercati in `/usr/share/icons`, `$XDG_DATA_HOME/icons` e `~/.icons`. Un tema configurato che non è installato, o un valore che contiene `/` o è `..`, torna al valore predefinito della stessa modalità e registra un messaggio, quindi il desktop non punta mai a un tema mancante. Un cambio di tema o modalità utilizza la scelta dell'icona del profilo del tema esportato quando presente, altrimenti ripristina il valore predefinito della modalità inclusa. Esporta il tema per preservare una scelta di icona personalizzata tra i cambi.

Usa i controlli del font nel Centro di Controllo. Le preferenze dei font sono canoniche in `config.json`, a `fonts.targets.<target>` per famiglia, stile e dimensione oltre a `fonts.rendering` per antialiasing, hinting, ordine dei sottopixel e DPI. Il Centro di Controllo le conserva attraverso `argvus-config`; non scrive file dei consumatori da solo. `argvus-config` poi proietta `data/generated/fonts.conf` e riscrive il blocco di font delimitato all'interno di `data/waybar/argvus-taskbar.css` e `data/waybar/argvus-widget-telemetry.css`, così le modifiche del font al di fuori di quei blocchi sopravvivono a un cambiamento di font. Le regole del terminale e di GTK fontconfig rimangono destinazioni native dell'adattatore. Il pacchetto esegue l'aggiornamento della cache dei font durante l'installazione.

La generazione del modulo della barra delle applicazioni convalida il JSONC risultante prima della pubblicazione. Le liste del modulo delle utilità vengono ricostruite dalle preferenze abilitate, includendo un espansore del cassetto solo in modalità hover. La modalità icona della workspace rende `{windows}` insieme a `{name}`. La visibilità della tray di sistema influisce solo sulle icone delle applicazioni in background.

Il proiettore del gruppo utilità preserva custom/ai quando abilitato nei moduli opzionali e definito dal template della barra delle applicazioni. Il suo glifo nf-md-robot (U+F06A9) apre il menu degli agenti AI condivisi; la disponibilità resta controllata dal modulo, anche quando tutte le altre icone delle utilità sono disabilitate.

La visibilità dell'icona AI è controllata da /taskbar/icons/ai_agents_enabled (predefinito true), esposta sotto Centro di Controllo > Aspetto > Barra delle Applicazioni > Icone > Moduli opzionali > Agenti AI. Il proiettore rispetta lo stato disabilitato a ogni applicazione e mantiene il gruppo utilità quando sono abilitati solo gli Agenti AI.

Il proiettore della barra delle applicazioni posiziona lo Stato Aggiornamenti in un gruppo separato tra Utilità e il gruppo rete/performance quando `/taskbar/icons/update_status_enabled` è vero. Inoltre aggiorna le configurazioni generate precedentemente con la definizione del modulo.

L'helper è `argvus window-mode-menu`; `argvus window-mode-menu --status` emette Waybar JSON. Viene distribuito dal pacchetto master `argvus`. Le copie personalizzate della barra delle applicazioni esistenti vengono preservate: aggiungere la definizione del modulo `custom/window-mode` e la voce del gruppo dal modello confezionato per partecipare, oppure usare il Centro di Controllo. Il proiettore dell'aspetto preserva il modulo quando la sua definizione è presente, anche se altre icone delle utilità sono disabilitate.

I consumatori di temi `window-bar` e `window-controls` derivano i loro colori da bg, fg e accent. I colori della barra del titolo si ricaricano tramite `argvus windows decorations`; la barra della finestra osserva il suo foglio di stile generato. Tile/Floating è indipendente dalla geometria dell'aspetto Sticky/Spaced.
