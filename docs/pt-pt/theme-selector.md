---
title: Seletor visual de temas
---

Abra `argvus theme-selector`, `argvus theme-switch` sem argumentos ou `SUPER + Shift + T`. O overlay GTK independente abre no monitor ativo, com pré-visualização central e cartões vizinhos. Pesquise ou filtre Todos/Escuros/Claros; navegue com setas, roda do rato ou cartões laterais. Enter ou Aplicar tema confirma; Escape ou Fechar cancela. Navegar nunca altera o ambiente. Os temas do sistema e do utilizador usam o catálogo existente. Uma imagem `preview` válida tem preferência; caso contrário, o papel de parede e a paleta compõem um ambiente ilustrativo, sem reproduzir exatamente as personalizações das aplicações. A aplicação usa a transação existente e preserva Sticky/Spaced. Os erros permitem nova tentativa. Miniaturas JXL precisam de `djxl`, do pacote `libjxl`; o cache derivado fica no cache XDG em `argvus/theme-selector/v2`.

Prima `/` para focar ou sair da pesquisa; o campo recebe texto assim que o seletor abre. **Personalizado** apresenta temas instalados pelo utilizador; **Escuro** e **Claro** apresentam temas do sistema de cada categoria. A linha de pesquisa acompanha a largura da pré-visualização central. Sticky usa cantos retos em toda a interface; Spaced mantém os cantos arredondados. O estilo compacto e monoespaçado acompanha os utilitários do ARGVUS.
