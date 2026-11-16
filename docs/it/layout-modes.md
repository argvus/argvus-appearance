---
title: Modalità di layout
description: Scegli il layout del desktop Sticky o Spaced.
---
Sticky mantiene compatte le finestre e le superfici delle shell. Spaced utilizza spazi maggiori, angoli arrotondati e margini più ampi della barra delle applicazioni. La modalità di layout è indipendente dal tema selezionato; cambiare modalità riapplica la geometria di quella modalità.

Scegli la modalità in **Centro di Controllo → Aspetto → Desktop → Modalità Aspetto** oppure apri il selettore con `SUPER + Shift + M`. L'impostazione canonica è `/layout/variant`, con valori `sticky` e `spaced`. Gli ID del tema Spaced risolti utilizzano il suffisso `-spaced`. I valori `float` e gli ID `-float` esistenti rimangono leggibili per compatibilità.

`argvus layout-mode-menu` (SUPER + Shift + M): Scegli Sticky o Spaced con ↑/↓. Le quattro schede a destra combinano finestre affiancate o mobili e barra in alto o in basso; ←/→ le percorre senza ciclo. Clic per selezionare, Invio per applicare, Esc per annullare. La modalità non selezionata è attenuata; le anteprime usano tema e sfondo attuali. Le applicazioni in attesa restano visibili e gli errori consentono di riprovare.
