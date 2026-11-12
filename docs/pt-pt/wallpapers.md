---
title: Papéis de parede
description: Use wallpapers integrados e personalizados.
---

`argvus-wallpapers` instala wallpapers JPEG XL em `/usr/share/backgrounds/argvus/`. Em **Control Center → Aparência → Wallpapers**, eles são organizados por `Abstrato` ou `Paisagem` e depois por `Escuro` ou `Claro`. Os ficheiros `argvus-dark.jxl` e `argvus-light.jxl` da raiz aparecem nos grupos de fallback abstratos. A troca de tema usa apenas os ficheiros abstratos em `abstract/dark` e `abstract/light`; os ficheiros de paisagem são opções manuais extras. Prima `SUPER + Y` para abrir diretamente esse ecrã do Control Center. A primeira entrada também permite escolher uma imagem personalizada da HOME, que passa a ser o estado de wallpaper personalizado do utilizador.

A primeira entrada abre um seletor de ficheiros para uma imagem personalizada. Um wallpaper personalizado fica em `/appearance/wallpaper`, junto com `/appearance/wallpaper_custom`, na configuração canônica, e `argvus config` o projeta na configuração de wallpaper do Hyprland consumida pela sessão. Ele permanece ativo até uma troca de tema ou modo reaplicar o wallpaper do tema. Exporte o tema ativo para incluir o wallpaper atual e preservá-lo no tema exportado. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` é apenas uma entrada de migração legada.

Ao exportar um tema, a imagem do wallpaper atual é incluída quando está legível. Importar instala o tema; aplicá-lo ativa seu wallpaper. Veja [Importando e exportando temas](/pt/docs/components/argvus-themes/import-and-export/).

Os controles de aparência usam o helper Hyprland `hypr-wallpaper-pick.sh`, que registra o caminho escolhido pelo `argvus config` em vez de guardar o estado de wallpaper por conta própria. Não edite diretamente a configuração de wallpaper gerada.
