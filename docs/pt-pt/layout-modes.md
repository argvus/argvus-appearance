---
title: Modos de layout
description: Escolha o layout Sticky ou Spaced do ambiente de trabalho.
---

Sticky mantém janelas e superfícies do shell compactas. Spaced usa gaps maiores, cantos arredondados e margens maiores na taskbar. O modo é independente do tema selecionado; trocar de modo reaplica a geometria correspondente.

Escolha o modo em **Central de Controle → Aparência → ambiente de trabalho → Modo de aparência** ou abra o seletor com `SUPER + Shift + M`. A configuração canônica é `/layout/variant`, com os valores `sticky` e `spaced`. IDs de tema resolvidos para Spaced usam o sufixo `-spaced`. Valores `float` e IDs `-float` anteriores continuam sendo aceitos por compatibilidade.

`argvus layout-mode-menu` (SUPER + Shift + M): **Tab / Shift+Tab**: Sticky/Spaced ⇄ Tile/Floating · Taskbar Top/Bottom. Escolha Sticky ou Spaced com ↑/↓. Os quatro cartões à direita combinam janelas em mosaico ou flutuantes com a barra no topo ou em baixo; ↑/↓/←/→ percorre as opções sem voltar ao início. Clique para selecionar, Enter para aplicar ou Escape para cancelar. O modo não selecionado fica esbatido; as pré-visualizações usam o tema e papel de parede atuais. Aplicações pendentes permanecem visíveis e falhas permitem nova tentativa.

As aplicações iniciadas pelos seletores de temas e modos mostram o progresso no próprio seletor, sem splash da sessão. As mudanças de modo preparam a posição final da taskbar antes de recarregar; os reinícios necessários são agrupados numa transação do systemd.
