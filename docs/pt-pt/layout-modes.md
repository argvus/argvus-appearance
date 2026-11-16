---
title: Modos de layout
description: Escolha o layout Sticky ou Spaced do ambiente de trabalho.
---

Sticky mantém janelas e superfícies do shell compactas. Spaced usa gaps maiores, cantos arredondados e margens maiores na taskbar. O modo é independente do tema selecionado; trocar de modo reaplica a geometria correspondente.

Escolha o modo em **Central de Controle → Aparência → ambiente de trabalho → Modo de aparência** ou abra o seletor com `SUPER + Shift + M`. A configuração canônica é `/layout/variant`, com os valores `sticky` e `spaced`. IDs de tema resolvidos para Spaced usam o sufixo `-spaced`. Valores `float` e IDs `-float` anteriores continuam sendo aceitos por compatibilidade.

`argvus layout-mode-menu` (SUPER + Shift + M): Escolha Sticky ou Spaced com ↑/↓. Os quatro cartões à direita combinam janelas em mosaico ou flutuantes com a barra no topo ou em baixo; ←/→ percorre as opções sem voltar ao início. Clique para selecionar, Enter para aplicar ou Escape para cancelar. O modo não selecionado fica esbatido; as pré-visualizações usam o tema e papel de parede atuais. Aplicações pendentes permanecem visíveis e falhas permitem nova tentativa.
