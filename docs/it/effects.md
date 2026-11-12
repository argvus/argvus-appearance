---
title: Effetti
description: Configura le animazioni, la sfocatura globale di Hyprland e la trasparenza per superficie.
---
**Centro di Controllo → Hyprland** contiene **Animazioni**, **Sfocatura** e **Bordi**, la cui pagina **Ombra** controlla l'ombra della finestra. Gli interruttori per abilitare la trasparenza sono impostazioni per superficie nelle rispettive pagine Aspetto.

Gli interruttori delle superfici sono indipendenti. La pagina di Configurazione del Centro di Controllo ha il proprio valore di Trasparenza e l'interruttore per abilitare la Sfocatura; la sua sfocatura utilizza i valori globali di Sfocatura.

Il Centro di Controllo viene lanciato tramite Foot con un profilo generato dedicato su `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. Con Foot 1.28, la trasparenza viene proiettata su `[colors-dark] alpha` e l'interruttore della Sfocatura della superficie su `[colors-dark] blur`; la configurazione normale di Foot e il terminale ARGVUS rimangono indipendenti.

## Interruttori Animazioni ed Effetti

Ci sono due interruttori principali indipendenti, entrambi applicati a `hyprland.lua` tramite le impostazioni canoniche `/effects`:

- **Animazioni** (`/effects/animations`) controlla tutto ciò che si muove: spazio di lavoro, finestra, dissolvenza, animazioni di bordo e di livello.
- **Effetti** è un collegamento per sfocatura (`/effects/blur_global_enabled`) e la trasparenza di Terminal, Launcher, Widget Telemetry, Pannello di Controllo e Barra delle applicazioni (`/effects/transparency_<surface>_enabled`). Attivandolo o disattivandolo vengono scritti tutti questi valori (e anche la trasparenza del Centro di Controllo). Ogni superficie mantiene la propria pagina di trasparenza, quindi Effetti viene letto come **attivo quando almeno uno di essi è attivato** e come disattivato solo quando tutti sono disattivati.

Usa `argvus effects-toggle animations status|enable|disable|toggle` e `argvus effects-toggle effects status|enable|disable|toggle`. La scheda Aspetto del Pannello di Controllo mostra un interruttore per ciascuno. Spegnere un interruttore principale mantiene ogni impostazione fine delle pagine **Animazioni** e **Sfocatura** (velocità, curve, interruttori per foglio, dimensione della sfocatura e passaggi), quindi riaccenderlo ripristina lo stesso aspetto. `effects status` stampa `enabled` quando la sfocatura o almeno una di quelle superfici trasparenti è attivata. Spegnere la trasparenza di una superficie rende opaca l'intera superficie di Waybar: oltre allo sfondo, i bordi traslucidi della barra delle applicazioni e del Widget Telemetria diventano del colore pieno che mostrano sullo sfondo del tema. Ogni effetto è abilitato per impostazione predefinita in un'installazione fresca, comprese le macchine virtuali e le sessioni a basso consumo; solo un'impostazione esplicita lo disattiva.

## Tutti gli effetti insieme

`argvus effects-toggle` senza un componente agisce su animazioni, sfocatura e trasparenza insieme: `status` stampa `enabled` solo quando tutti e tre sono abilitati, `enable` e `disable` commutano tutti e tre, e `toggle` spegne tutto quando `status` è `enabled` e lo accende altrimenti. **SUPER + F6** esegue questo interruttore. Per agire su un singolo gruppo, assegnargli un nome: `argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`. La pagina **Animazioni** del Centro di Controllo utilizza la forma per componente, quindi il suo interruttore **Abilita** cambia ancora solo le animazioni.

## Trasparenza

Ogni superficie ha il proprio sottomenu **Trasparenza** con un interruttore di abilitazione e un valore.

La pagina **Aspetto → Launcher** controlla il launcher ufficiale basato su Rofi e i flussi del selezionatore: il launcher principale, il selezionatore di emoji, la calcolatrice, il selezionatore degli appunti, i cheatsheet e i menu dei dispositivi rimovibili di Rofi. Il suo valore di Trasparenza è l'alpha finale dello sfondo, quindi `50` significa un'opacità effettiva dello sfondo di circa `0.50`; testo, icone e righe selezionate rimangono opachi. Con la Trasparenza disattivata, il launcher utilizza il colore di sfondo del tema attivo, completamente opaco. L'interruttore Sfocatura applica lo strato `rofi` alle impostazioni globali di Sfocatura.

Ogni valore varia da `0%` (opaco) a `100%` (completamente trasparente). Usa `+` e `-` in incrementi del 5%, quindi seleziona **Applica** sulla pagina principale. Uscire dalla pagina annulla una bozza non applicata.

Usa `↑` e `↓` per muoverti tra **Enable** e **Value**. Sulla riga **Value**, `+` e `-` regolano la bozza senza cambiare il focus. Premi `Tab` per aprire **Actions**, quindi attiva **[ Apply ]**; `Esc` ritorna alla pagina principale della superficie.

## Animazioni

Apri **Control Center → Hyprland → Animations**. La pagina ha un interruttore **Enable** e un elenco di **Options** con **Custom curves** e cinque categorie. Ogni categoria elenca le sue animazioni, e ogni animazione ha la propria pagina con **Style**, **Speed**, **Curve** e, per l'apertura e chiusura delle finestre, **Pop-in percentage**. Le animazioni che Hyprland può disattivare hanno anche una riga **Enable**.

Ogni valore in queste pagine appartiene a una bozza condivisa da tutto l'albero delle Animazioni. Nulla viene scritto fino a quando non viene selezionato **[ Applica ]** in fondo a una qualsiasi di esse. Muoversi tra le pagine mantiene la bozza; lasciare la pagina Animazioni con una bozza non applicata richiede conferma. Applicare scrive i valori modificati in un'unica operazione e ricarica Hyprland. L'interruttore **Abilita** in alto è lo stato globale delle animazioni (`effects.animations`): quando è spento, tutte le animazioni sono disabilitate, a prescindere dal loro interruttore individuale.

Controlli: `↑/↓` sposta tra le righe; `←/→` (o `+/-`) cambia il valore selezionato e cicla **Stile** e **Curva**; `Enter` inserisce un valore esatto per **Velocità**, **Percentuale Pop-in** o parametro della curva (i valori fuori intervallo vengono rifiutati), e cicla in avanti **Stile** e **Curva**.

### Categorie e animazioni

| Categoria | Animazione | Tasto (`effects.animation_<key>_*`) | Stile (predefinito) | Velocità | Abilita |
|---|---|---|---|---|---|
| Finestre | Apertura delle finestre | `opening` | `popin`, pop-in 87% | 4.1 | — |
| Finestre | Chiusura delle finestre | `closing` | `popin`, pop-in 87% | 1.49| — |
| Finestre | Finestre mobili | `moving` | — | 4.79| sì |
| Spazi di lavoro | Cambio di area di lavoro | `switching` | `fade` | 1,94 | — |
| Spazi di lavoro | Ingresso spazio di lavoro | `workspace_in` | `fade` | 1.21 | — |
| Spazi di lavoro | Uscita dall'area di lavoro | `workspace_out` | `fade` | 1,94 | — |
| Spazi di lavoro | Spazi di lavoro speciali | `special_workspace` | `slide` | 5| — |
| Livelli e popup | Superfici degli strati | `layers` | — | 3.81| sì |
| Livelli e popup | Ingresso livello | `layers_in` | `fade` | 4| — |
| Livelli e popup | Uscita dal livello | `layers_out` | `fade` | 1,5 | — |
| Livelli e popup | Dissolvenza | `fade` | — | 3.03| sì |
| Livelli e popup | Dissolvenza in entrata | `fade_in` | — | 1,73 | sì |
| Livelli e popup | Dissolvenza | `fade_out` | — | 1.46| sì |
| Confini ed effetti | Colore del bordo | `border` | — | 5.39| sì |
| Bordi e effetti | Angolo del gradiente del bordo | `border_angle` | — | 5 | sì |
| Altre animazioni | Fattore di zoom | `zoom` | — | 7 | sì |
| Altre animazioni | Monitor aggiunto | `monitor_added` | — | 5 | sì |

I valori predefiniti delle foglie che Hyprland 0.56.2 include nella sua configurazione di base (tutte le righe tranne Spazi di lavoro speciali, Angolo del gradiente del bordo e Monitor aggiunto) sono le velocità, gli stili e le curve di base. Quelle tre mantengono i valori predefiniti di ARGVUS, perché la configurazione di base non li definisce.

Ogni foglia offre solo gli stili accettati da Hyprland 0.56.2 per essa. L'apertura e la chiusura delle finestre offrono `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` e `gnomed`. L'ingresso e l'uscita dei layer offrono `slide`, `popin`, `fade`, `slidefade`, `slidevert` e `slidefadevert`. Le foglie degli spazi di lavoro (cambio, ingresso, uscita e spazi di lavoro speciali) offrono `slide`, `fade`, `slidefade`, `slidevert` e `slidefadevert`, senza `popin` o `gnomed`. Uno stile memorizzato al di fuori della lista della sua foglia viene ignorato e la foglia utilizza quello predefinito. Ogni animazione inizia con la curva `default`. Una pagina offre solo le righe supportate dalla sua animazione. Le chiavi memorizzate sono `effects.animation_<key>_speed`, `_curve`, `_style` (dove offerte), `_popin` (apertura e chiusura delle finestre) e `_enabled` (dove offerte).

### Curve

| Curva | Comportamento | Parametri (chiave → predefinito) |
|---|---|---|
| `default` | La curva fornita da Hyprland 0.56.2 per quell'animazione (per esempio `easeOutQuint`, `almostLinear`, `quick`, `linear` o la molla `easy`). Le animazioni senza una curva predefinita usano la Bézier incorporata di ARGVUS. | Fisso. |
| `bezier` | Movimento fluido che accelera e decelera, modellato da due punti di controllo. | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Movimento fisico con massa, rigidità e ammortizzazione; può superare il limite per un effetto elastico. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | Velocità costante per tutta l'animazione, da `(0, 0)` a `(1, 1)`. | Fisso. |
| `ease_out` | Veloce all'inizio e fluido alla fine, da `(0, 0)` a `(0.58, 1)`. | Fisso. |

Sotto **Curve personalizzate**, ogni curva ha la propria pagina. Bézier modifica i suoi quattro punti di controllo, Spring modifica massa, rigidità e smorzamento, e Linear ed Ease-out mostrano i loro punti fissi. I valori di Bézier e Spring si applicano a ogni animazione che seleziona quella curva.

Intervalli e passi: **Velocità** 1–10 con decimali (passo 0,1, le velocità standard sono decimali); **Percentuale Pop-in** 1–100 in numeri interi (passo 5, standard 87); punti Bézier come sopra (passo 0,05); massa Spring 0,5–10 (passo 0,1), rigidità 0,5–2000 (passo 10) e smorzamento 0,5–200 (passo 1).

Non offerto: Hyprland 0.56.2 non ha animazioni separate per il ridimensionamento delle finestre, per i popup o per gli angoli dei gradienti di ombra e bagliore, quindi la pagina non mostra righe per loro.

## Sfocatura

Il Blur è un'impostazione globale di Hyprland, condivisa da ogni superficie che vi partecipa. Apri **Centro di Controllo → Hyprland → Blur**. La pagina ha un interruttore **Abilita** e una lista **Valori** con i parametri di `decoration:blur` di Hyprland, sotto i nomi usati da Hyprland:

| Riga | Chiave di configurazione | Default | Intervallo | Passo `←/→` |
|---|---|---|---|---|
| Dimensione | `effects.blur_size` | `6` | 1–64 | 1 |
| Passaggi | `effects.blur_passes` | `2` | 1–8 | 1 |
| Luminosità | `effects.blur_brightness` | `1` | 0–2 | 0,05 |
| Rumore | `effects.blur_noise` | `0.00` | 0–1 | 0,01 |
| Contrasto | `effects.blur_contrast` | `0.900000` | 0–2 | 0,05 |
| Vividezza | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0,01 |
| Oscurità vividezza | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0,01 |

Usa `↑/↓` per muoverti, `←/→` (o `+/-`) per modificare il valore selezionato di uno step, e `Enter` per inserire un valore esatto; i valori al di fuori dell'intervallo vengono rifiutati. Nulla viene scritto durante la modifica: l'interruttore e i valori rimangono nella bozza fino a quando non si seleziona **[ Applica ]** in fondo alla pagina. Applica scrive tutti i valori modificati in un'unica chiamata e ricarica Hyprland dopo di essa. Uscire dalla pagina con una bozza non applicata richiede conferma.

I valori vengono passati a Hyprland così come sono; ARGVUS non li deriva da una percentuale. Modificare l'interruttore di una superficie non cambia i valori.

## Ombra

L'ombra della finestra è un'impostazione globale di Hyprland, sotto **Centro di Controllo → Hyprland → Bordi → Ombra**. È indipendente dalla trasparenza e dalla sfocatura: è disattivata per impostazione predefinita, e attivare o disattivare la trasparenza di una superficie non la modifica.

| Riga | Chiave di configurazione | Predefinito | Intervallo | Passo `←/→` |
|---|---|---|---|---|
| Abilita | `effects.shadow_enabled` | `false` | — | — |
| Nitidezza | `effects.shadow_sharp` | `false` | — | — |
| Colore | `effects.shadow_color` | vuoto (segue l'accento) | vuoto o `RRGGBBAA` | — |
| Intervallo | `effects.shadow_range` | `6` | 0–100 | 1 |
| Potenza di rendering | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| Offset X | `effects.shadow_offset_x` | `0` | −100 a 100 | 1 |
| Offset Y | `effects.shadow_offset_y` | `0` | −100 a 100 | 1 |
| Scala | `effects.shadow_scale` | `1.00` | 0–1 | 0,05 |

Un colore vuoto segue l'accento del tema attivo con alpha `99`, quindi l'accento blu predefinito restituisce `3590bd99`. Digita otto cifre esadecimali (`RRGGBBAA`) per correggere il colore, oppure lascia il prompt vuoto per seguire di nuovo l'accento. Il colore viene letto quando la configurazione di Hyprland si carica, quindi dopo una modifica del tema o dell'accento assume il nuovo accento al successivo caricamento della configurazione.

Come Blur, la pagina modifica una bozza: nulla viene scritto fino a quando non viene selezionato **[ Applica ]**, e uscire dalla pagina con una bozza non applicata richiede una conferma.

## Stato canonico e file di compatibilità

La preferenza logica è memorizzata in `$XDG_CONFIG_HOME/argvus/config.json`. L'animazione globale utilizza `effects.animations`; i valori delle Animazioni utilizzano le chiavi `effects.animation_*` descritte sopra. L'interruttore globale Blur è `effects.blur_global_enabled`, e i valori Blur utilizzano le chiavi `effects.blur_*` elencate sopra. Gli stati di abilitazione delle superfici e i valori di trasparenza utilizzano chiavi come `effects.blur_control-center_enabled` e `effects.transparency_control-center_value`. I valori di trasparenza sono limitati a `0–100`; ogni valore Blur è limitato al proprio intervallo, e `argvus-config` rifiuta scritture al di fuori di esso. Gli stati di abilitazione rimangono distinti dagli override mancanti.

La percentuale precedente `effects.blur_global_value` non viene più letta. Un profilo che la contiene ancora mantiene la chiave sul disco senza effetto, e Blur utilizza i valori predefiniti sopra indicati fino a quando i suoi valori vengono applicati.

```text
$XDG_CONFIG_HOME/argvus/config.json
```
`data/generated/effects/<active-theme>.conf` è la proiezione degli effetti, scritta solo da `argvus config`; `argvus effects-toggle` delega a `argvus config effects`. Un cambio di tema o di modalità riapplica il profilo visivo esportato del tema attivo, inclusi i valori per superficie da `effects.conf` quando presenti. I temi senza profilo ripristinano i valori predefiniti degli effetti inclusi. Esporta il tema dopo aver modificato gli effetti se desideri che tali valori sopravvivano a un altro cambio di tema o di modalità.

Disabilitare l'interruttore di Trasparenza o Sfocatura di una superficie influisce solo su quella superficie; i valori numerici salvati vengono mantenuti per un successivo riattivamento.

## Profili

L'esportazione del tema include le impostazioni canoniche di aspetto/effetti e la proiezione degli effetti per superficie del tema attivo. I file runtime generati di Waybar, Quickshell e Hyprland vengono rigenerati quando il tema viene applicato.

Tutte le pagine di superficie applicano le loro bozze insieme al pulsante `[ Apply ]`. Il Centro di Controllo scrive il documento canonico tramite l'assistente degli effetti, permette a `argvus-config` di proiettare l'albero degli effetti, ricarica i consumatori interessati e legge nuovamente il valore effettivo. I file generati vengono ricreati piuttosto che importati come stato autorevole.

## Luce notturna

**SUPER + Shift + B** mantiene il selettore della luminosità e aggiunge un toggle Night Light separato con stato/temperatura effettiva. Chiama `argvus config display night-light status|toggle`. Night Light richiede Hyprland e un Hyprsunset rispondente >= 0.4.0, indipendentemente dal supporto della luminosità. L'intervallo è 1000–20000 K; la configurazione si trova sotto **Desktop & Input > Displays > Night Light** nel Centro di Controllo. Un toggle è persistente senza programmazione, oppure un override volatile fino alla prossima transizione con programmazione. Annullare il menu non cambia nulla.
