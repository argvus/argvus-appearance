---
title: Wallpapers
description: Use wallpapers integrados e personalizados.
slug: pt/0.4.0/docs/user-guide/appearance/wallpapers
---

`argvus-wallpapers` instala wallpapers JPEG XL em `/usr/share/backgrounds/argvus/`. Em **Control Center → Aparência → Wallpapers**, eles são organizados por `Abstrato` ou `Paisagem` e depois por `Escuro` ou `Claro`. Os arquivos `argvus-dark.jxl` e `argvus-light.jxl` da raiz aparecem nos grupos de fallback abstratos. A troca de tema usa apenas os arquivos abstratos em `abstract/dark` e `abstract/light`; os arquivos de paisagem são opções manuais extras. Pressione `SUPER + Y` para abrir diretamente essa tela do Control Center. A primeira entrada também permite escolher uma imagem personalizada da HOME, que passa a ser o estado de wallpaper personalizado do usuário.

A primeira entrada abre um seletor de arquivos para uma imagem personalizada. Um wallpaper personalizado é um estado independente do usuário: fica em `/appearance/wallpaper`, junto com `/appearance/wallpaper_custom`, no `config.json`, e o `argvus-config` o projeta na configuração de wallpaper do Hyprland consumida pela sessão. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` é apenas uma entrada de migração legada. Selecionar outro wallpaper incluído substitui essa escolha personalizada; isso não altera a definição lógica do tema.

Quando um perfil de tema é exportado, o wallpaper personalizado atual só é incluído quando é um arquivo legível. Importar um perfil restaura o wallpaper empacotado em um local gerenciado quando possível; se o caminho original não estiver disponível, o perfil importado não aponta silenciosamente para um arquivo inexistente. Veja [Importando e exportando temas](/pt/docs/argvus-themes/import-and-export/) para a separação entre importar e aplicar um perfil.

Os controles de aparência usam o helper Hyprland `hypr-wallpaper-pick.sh`, que registra o caminho escolhido pelo `argvus-config` em vez de guardar o estado de wallpaper por conta própria. Aplicar um perfil de tema personalizado pode restaurar seu wallpaper incorporado, mas importar o perfil sozinho não o ativa. Não edite diretamente a configuração de wallpaper gerada.
