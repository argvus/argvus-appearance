---
title: Fontes e ícones
description: Configure fontes e temas de ícones.
slug: pt/0.4.0/docs/user-guide/appearance/fonts-and-icons
---

`argvus-fonts` instala fontes em `/usr/share/fonts/` e `argvus-icons` instala os temas de ícones ARGVUS. Use os controles de fonte no Control Center; as preferências são materializadas nos arquivos gerados.

## Fonte principal

A fonte principal padrão do ARGVUS é **IBM Plex Mono**, com o estilo `Regular`. Ela é a família padrão usada pelos alvos de fonte expostos no Control Center. O pacote incluído `argvus-fonts` fornece IBM Plex Mono e as famílias auxiliares de ícones/terminal usadas pelo desktop.

Abra **Control Center → Fontes** para configurar alvos individuais:

* taskbar;
* telemetria/informações do sistema;
* Control Panel;
* interface do sistema ARGVUS;
* aplicativos;
* terminal;
* navegador.

Os tamanhos padrão são específicos por alvo: taskbar, sistema e terminal usam `13`; telemetria e Control Panel usam `14`; aplicativos usam `12`; e navegador usa `10`. Esses padrões podem ser restaurados pela página Fontes.

As preferências de fonte são canônicas no `config.json`, em `fonts.targets.<alvo>` para família, estilo e tamanho, mais `fonts.rendering` para antialiasing, hinting, ordem de subpixel e DPI. O Control Center as persiste através do `argvus-config`; ele não escreve arquivos consumidor sozinho. O `argvus-config` então projeta `data/generated/fonts.conf` e reescreve o bloco de fonte delimitado dentro de `data/waybar/argvus-taskbar.css` e `data/waybar/argvus-widget-telemetry.css`, então edições de fonte feitas fora desses blocos sobrevivem a uma mudança de fonte. As regras de fontconfig do terminal e do GTK continuam sendo alvos nativos de adapter. O pacote atualiza o cache de fontes durante a instalação.
