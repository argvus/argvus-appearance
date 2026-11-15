---
title: Seletor visual de temas
---

Abra `argvus theme-selector`, `argvus theme-switch` sem argumentos ou `SUPER + Shift + T`. O overlay GTK independente abre no monitor ativo, com prévia central e cartões vizinhos. Busque ou filtre Todos/Escuros/Claros; navegue por setas, roda do mouse ou cartões laterais. Enter ou Aplicar tema confirma; Escape ou Fechar cancela. Navegar nunca altera o desktop. Temas instalados do sistema e do usuário usam o catálogo existente. Uma imagem `preview` válida do manifesto tem preferência; caso contrário, wallpaper e paleta compõem um desktop ilustrativo, sem reproduzir exatamente os overrides das aplicações. Imagens ausentes usam cores da paleta. A aplicação utiliza a transação existente e preserva Sticky/Spaced. Falhas ficam visíveis para nova tentativa. Miniaturas JXL precisam de `djxl`, do pacote `libjxl`; o cache derivado fica no cache XDG em `argvus/theme-selector/v2`.

Pressione `/` para focar ou sair da busca; o campo recebe digitação assim que o seletor abre. **Custom** lista temas instalados pelo usuário; **Dark** e **Light** listam temas do sistema de cada categoria. A linha de busca acompanha a largura da prévia central. Sticky usa cantos retos em toda a interface; Spaced mantém os cantos arredondados. O visual compacto e monoespaçado acompanha os utilitários do ARGVUS.
