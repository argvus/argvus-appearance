---
title: Temas e acentos
description: Selecione tema, modo e cor de destaque.
slug: pt/0.4.0/docs/user-guide/appearance/themes
---

O ARGVUS fornece vinte e quatro famílias oficiais, cada uma com os modos Sticky e Float. Em **Control Center → Aparência → Temas**, abra **Temas oficiais**, depois escolha **Escuro** ou **Claro**, uma família e seu modo:

* **Escuro** — One Dark, Dracula, ARGVUS Dark, Silver, Slate, Universe, Gruvbox High, Gruvbox, Catppuccin Latte, Rosé Pine, Tokyo Night, Solitude, Sunset, Hackerman e Monokai Dark.
* **Claro** — ARGVUS Light, GitHub, Solarized, One Light, Flexoki Light, Everforest Light, ARGVUS Kanagawa Lotus, Nord Light e Light Gruvbox.

Perfis personalizados importados permanecem em uma entrada separada de **Temas personalizados**. O catálogo oficial contém todas as famílias de aparência empacotadas; cada família oferece os modos **Sticky** e **Float**.

| Família | Cor de destaque restaurada | Fundo base | Sticky | Float |
| --- | --- | --- | --- | --- |
| One Dark | `#61AFEF` | `#282C34` | compacto, quadrado | espaçoso, arredondado |
| Dracula | `#BD93F9` | `#282A36` | compacto, quadrado | espaçoso, arredondado |
| ARGVUS Dark | `#3590bd` | `#111316` | compacto, quadrado | espaçoso, arredondado |
| Silver Dark | `#595959` | `#111316` | compacto, quadrado | espaçoso, arredondado |
| Slate Dark | `#7391a5` | `#2f3541` | compacto, quadrado | espaçoso, arredondado |
| Universe | `#eeeeee` | `#000000` | compacto, quadrado | espaçoso, arredondado |
| ARGVUS Gruvbox High | `#D79921` | `#282828` | compacto, quadrado | espaçoso, arredondado |
| ARGVUS Gruvbox | `#D4BE98` | `#282828` | compacto, quadrado | espaçoso, arredondado |
| ARGVUS Light | `#181818` | `#f7f7f7` | compacto, quadrado | espaçoso, arredondado |
| GitHub Light | `#0969DA` | `#FFFFFF` | compacto, quadrado | espaçoso, arredondado |
| Solarized Light | `#268BD2` | `#FDF6E3` | compacto, quadrado | espaçoso, arredondado |
| One Light | `#4078F2` | `#FAFAFA` | compacto, quadrado | espaçoso, arredondado |
| Flexoki Light | `#205EA6` | `#FFFCF0` | compacto, quadrado | espaçoso, arredondado |
| Everforest Light | `#3A94C5` | `#FDF6E3` | compacto, quadrado | espaçoso, arredondado |
| ARGVUS Kanagawa Lotus | `#4D699B` | `#F2ECBC` | compacto, quadrado | espaçoso, arredondado |
| Nord Light | `#5E81AC` | `#ECEFF4` | compacto, quadrado | espaçoso, arredondado |

O One Light usa a paleta One Light solicitada: background `#FAFAFA`, foreground `#383A42`, surface `#FFFFFF`, foreground suave `#696C77`, borda `#D7DAE0`, acento padrão `#4078F2`, sucesso `#50A14F`, aviso `#C18401`, erro `#E45649`, ciano `#0184BC` e roxo `#A626A4`. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/light/one-light-abstract-light.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente.

Flexoki Light é o port ARGVUS da paleta Flexoki de Steph Ango, licenciada sob MIT ([fonte oficial](https://stephango.com/flexoki)). Seu ID estável é `flexoki-light`, o modo é `light` e a variante Float é `flexoki-light-float`. Usa o mapeamento upstream de papel e tinta: background `#FFFCF0`, background alternativo `#F2F0E5`, surface `#E6E4D9`, surface de hover `#DAD8CE`, surface ativa `#CECDC3`, foreground `#100F0F`, foreground suave `#6F6E69` e foreground tênue `#B7B5AC`. O destaque padrão é o `blue-600` oficial para Light, `#205EA6`; as cores semânticas usam os acentos oficiais `600`, reservando os tons `400` para variantes suaves. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/light/flexoki-light-abstract-light.jxl`. A substituição de Highlight Color continua independente. Esta é uma adaptação/port ARGVUS; a atribuição da paleta pertence a Steph Ango.

O Everforest Light é a variante oficial Everforest Light Medium. Seu ID estável é `everforest-light`, o modo é `light` e o destaque padrão é `#3A94C5`. O mapeamento ARGVUS usa background `#FDF6E3`, background alternativo `#F4F0D9`, surface `#E6E2CC`, foreground `#5C6A72`, foreground suave `#829181`, borda `#BDC3AF`, sucesso `#8DA101`, aviso `#DFA000`, erro `#F85552`, aqua `#35A77C`, laranja `#F57D26` e roxo `#DF69BA`. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/light/everforest-abstract-light.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente. A variante `everforest-light-float` mantém a paleta com a geometria Float.
O ARGVUS Kanagawa Lotus é a adaptação oficial clara da paleta Kanagawa Lotus. Seu ID estável é `argvus-kanagawa-lotus`, o modo é `light` e o destaque padrão é `#4D699B`. Usa tons de papel e tinta: background `#F2ECBC`, background alternativo `#E5DDB0`, surface `#DCD5AC`, foreground `#545464`, foreground suave `#716E61`, borda `#C7D7E0`, sucesso `#6F894E`, aviso `#CC6D00`, erro `#C84053` e info `#4E8CA2`. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/light/kanagawa-lotus-abstract-light.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente. A variante `argvus-kanagawa-lotus-float` mantém a mesma paleta com a geometria Float.

Nord Light é a interpretação clara do ARGVUS para a paleta oficial Nord em interfaces de bright ambiance. Seu ID público é `argvus-nord-light`, seu ID canônico é `nord-light` e seu modo é `light`; a variante Float é `nord-light-float`. Usa Snow Storm nos fundos e superfícies (`#ECEFF4`, `#E5E9F0`, `#D8DEE9`), Polar Night no texto (`#2E3440`, `#3B4252`, `#4C566A`), Frost na interação (`#5E81AC`, `#81A1C1`, `#88C0D0`) e Aurora nos estados semânticos (`#BF616A`, `#D08770`, `#EBCB8B`, `#A3BE8C`, `#B48EAD`). O destaque padrão é `#5E81AC`. Esses mapeamentos semânticos são derivados pelo ARGVUS; Nord Light não é apresentado como uma palette upstream separada. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/light/nord-light-abstract-light.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente.
| Catppuccin Latte | `#1E66F5` | `#EFF1F5` | compacto, quadrado | espaçoso, arredondado |
| Gruvbox Light | `#458588` | `#FBF1C7` | compacto, quadrado | espaçoso, arredondado |
| Rosé Pine | `#C4A7E7` | `#191724` | compacto, quadrado | espaçoso, arredondado |
| Tokyo-Night | `#7AA2F7` | `#1A1B26` | compacto, quadrado | espaçoso, arredondado |
| Solitude | `#798186` | `#101315` | compacto, quadrado | espaçoso, arredondado |
| Sunset | `#E2BE8A` | `#0F0F0F` | compacto, quadrado | espaçoso, arredondado |
| Hackerman | `#82FB9C` | `#0B0C16` | compacto, quadrado | espaçoso, arredondado |
| Monokai Dark | `#78DCE8` | `#2D2A2E` | compacto, quadrado | espaçoso, arredondado |

Pressione `SUPER + Shift + T` para abrir o seletor Rofi; depois escolha **Escuro** ou **Claro**, uma família e **Sticky** ou **Float**. Pressione a seta direita para avançar e a esquerda para voltar um nível; `Esc` fecha o seletor. A mesma hierarquia está disponível em **Control Center → Appearance → Themes**. Perfis personalizados importados permanecem em uma seção separada **Temas personalizados**. O Control Panel também pode oferecer uma ação rápida de aparência. Para escolher uma cor de destaque, use **Control Center → Appearance → Accents** com o color picker. Para aplicar uma cor RGB diretamente:

```sh
sh /usr/share/argvus/appearance/sh/accent-switch.sh '#17d174'
```

O valor aceita uma cor RGB válida de seis dígitos. Um accent customizado explícito sobrevive à troca de tema; accents pertencentes ao tema acompanham o manifesto selecionado. **Restaurar padrão do tema** limpa o estado de override customizado e volta ao accent do tema atual. Bordas e os demais consumidores de accent são projetados a partir do tema selecionado. O estado lógico fica em `$XDG_CONFIG_HOME/argvus/config.json`; `.active-theme`, `.accent-color` e `.accent-custom` são apenas entradas legadas de migração, e todo consumidor em `$XDG_CONFIG_HOME/argvus/data/generated` é escrito exclusivamente pelo `argvus-config`.

O Control Panel recarrega o tema somente depois que a projeção canônica termina. Se o arquivo de tema gerado estiver ausente, ele é recriado automaticamente; reaplicar um tema sem mudança efetiva não exige editar arquivos gerados nem reinicia o painel.

O `argvus-config` projeta o tema em todas as superfícies do ARGVUS — compositor, perfis Waybar e de telemetria, Quickshell, Rofi, Dunst, Hyprlock, Yazi, Superfile, perfis de terminal e Qt, GTK, o stylesheet de dispositivos removíveis e as cores do overlay Hyprtoolkit — e então o `accent-switch.sh --apply` reconcilia os consumidores externos. Assim, Float aplica janelas Rofi arredondadas além das superfícies arredondadas do compositor, da taskbar e do shell; as ações Rofi do ARGVUS usam essa projeção, não o padrão Sticky empacotado.

O Dracula usa a paleta oficial Dracula Classic. Seu ID estável é `dracula`, o destaque padrão é `#BD93F9`, com `#FF79C6` como acento secundário; o fundo principal é `#282A36`, a seleção é `#44475A`, o foreground é `#F8F8F2` e o texto suave é `#6272A4`. Selecioná-lo também associa o wallpaper empacotado `dracula-abstract-dark.jxl`. Uma cor de destaque escolhida manualmente continua sendo um override independente.

O Rosé Pine usa a paleta dark oficial do Rosé Pine: base `#191724`, surface `#1F1D2E`, overlay `#26233A`, muted `#6E6A86`, subtle `#908CAA`, text `#E0DEF4`, love `#EB6F92`, gold `#F6C177`, rose `#EBBCBA`, pine `#31748F`, foam `#9CCFD8` e iris `#C4A7E7`. Selecioná-lo associa o wallpaper empacotado `/usr/share/backgrounds/argvus/abstract/dark/rose-pine-abstract-dark.jxl`. Uma cor de destaque escolhida manualmente continua sendo um override independente.

O Tokyo-Night usa a paleta dark oficial do Tokyo Night: background `#1A1B26`, background escuro `#16161E`, superfície destacada `#292E42`, foreground `#C0CAF5`, foreground suave `#A9B1D6`, comentário `#565F89`, acento azul `#7AA2F7`, ciano `#7DCFFF`, verde `#9ECE6A`, laranja `#FF9E64`, roxo `#BB9AF7`, vermelho `#F7768E`, amarelo `#E0AF68` e teal `#1ABC9C`. Selecioná-lo associa `/usr/share/backgrounds/argvus/tokyo-night-abstract-dark.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente.

O GitHub GitHub Light segue a linguagem visual GitHub Light / Primer: background `#FFFFFF`, surface `#F6F8FA`, foreground `#1F2328`, foreground suave `#57606A`, borda `#D0D7DE`, acento `#0969DA`, sucesso `#1A7F37`, aviso `#9A6700` e erro `#CF222E`. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/light/github-light-abstract-light.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente.

O Solarized GitHub Light usa a paleta oficial Solarized Light de Ethan Schoonover: background `#FDF6E3`, surface alternativa `#EEE8D5`, foreground `#657B83`, foreground suave `#839496`, borda `#D8D2BE`, acento `#268BD2`, sucesso `#859900`, aviso `#B58900`, erro `#DC322F`, ciano `#2AA198`, violeta `#6C71C4` e magenta `#D33682`. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/light/solarized-abstract-light.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente.

O Solitude é baseado na paleta publicada do Solitude: background `#101315`, foreground `#CACCCC`, destaque padrão `#798186`, seleção `#798186` sobre `#101315` e uma escala discreta de superfícies e bordas em cinza frio. Seu aviso semântico usa `#C9C2B4` e o erro usa `#DE6145`; este último fica reservado para estados de atenção, não para o destaque padrão. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/dark/solitude-abstract-dark.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente.

O Sunset usa a paleta publicada do Aamis sob o nome oficial do ARGVUS: background `#0F0F0F`, foreground `#EADCCC`, destaque padrão `#E2BE8A`, surface `#1A1816`, surface alternativa `#211E1B`, borda `#3A332D`, aviso `#F4BB54`, erro `#E25D6C` e cream `#EDE4C8`. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/dark/sunset-abstract-dark.jxl`; uma cor de destaque escolhida manualmente continua sendo um override independente.

O Hackerman é baseado na identidade publicada do Hackerman: background `#0B0C16`, foreground `#DDF7FF` e destaque padrão `#82FB9C`. A escala derivada da UI usa surface `#141722`, surface alternativa `#1A1D29`, borda `#29303A`, foreground suave `#A7BEC5`, aviso `#E5D57A` e erro `#FF6B7A`. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/dark/hackerman-abstract-dark.jxl`; as cores ANSI do terminal são um fallback derivado porque a página publicada não fornece uma paleta ANSI completa. Uma cor de destaque escolhida manualmente continua sendo um override independente.

O Monokai Dark usa somente a paleta de cores publicada pelo Monokai Pro em [monokai.pro/contribute](https://monokai.pro/contribute), sob o nome independente do ARGVUS. Sua base é `#2D2A2E`, foreground `#FCFCFA` e destaque padrão `#78DCE8`; as superfícies derivadas do ARGVUS usam `#221F22`, `#403E41` e `#353237`, com texto suave `#C1C0C0`, texto sutil `#939293`, borda `#5B595C`, sucesso `#A9DC76`, aviso `#FFD866`, erro `#FF6188`, laranja `#FC9867` e roxo `#AB9DF2`. Selecioná-lo associa `/usr/share/backgrounds/argvus/abstract/dark/monokai-abstract-dark.jxl`. O mapeamento ANSI do terminal é um fallback derivado pelo ARGVUS, não uma definição ANSI oficial do Monokai Pro. Ícones e assets proprietários do Monokai Pro não são incluídos; uma cor de destaque escolhida manualmente continua sendo um override independente.

## Perfis personalizados

Em **Control Center → Aparência → Temas**, as ações de perfil podem exportar a aparência atual do ARGVUS para um arquivo `.tar.gz` com timestamp no seu diretório pessoal. O arquivo contém os arquivos lógicos de aparência permitidos e, quando o wallpaper atual puder ser descrito e lido, um payload de wallpaper validado. A saída de runtime gerada é regenerada quando o perfil é aplicado; ela não é a fonte de verdade do arquivo.

Importe um `.tar.gz` pela mesma página de Temas. O ARGVUS prepara e valida o arquivo, instala-o como perfil personalizado e o disponibiliza para seleção. Um conflito de nome recebe uma identidade distinta. Ao aplicar o perfil personalizado, o ARGVUS restaura estado de tema, overrides de acento/efeitos/layout e o wallpaper incluído quando o caminho original não estiver mais disponível. Se o wallpaper do perfil não puder ser restaurado como arquivo, o perfil é aplicado sem esse wallpaper e o marcador antigo é removido.

O perfil é um arquivo `argvus-theme-profile` versão 4 quando `argvus-config` está disponível. Ele contém um manifesto permitido, checksums e um `config.json` canônico com o escopo de aparência do tema ativo, layout, efeitos, fontes e cards do Control Panel. Arquivos versão 2 e 3 continuam importáveis, mas seus dot-files nativos são convertidos e não são instalados como estado de runtime. A saída gerada de Hyprland, Waybar e shell é recriada quando o perfil é aplicado; ela não é copiada como configuração autoritativa do perfil.

O perfil também carrega os valores de transparência e blur por superfície do tema ativo para Taskbar, Control Panel e Widget Telemetry. Valores salvos para temas inativos não são exportados intencionalmente.

Ao importar, o ARGVUS valida o arquivo antes de instalá-lo. O wallpaper incorporado é restaurado no home do usuário quando possível. Se o caminho original relativo ao home não estiver disponível, o ARGVUS usa a pasta de imagens do usuário ou `~/Pictures/ARGVUS`; uma colisão de nome recebe o sufixo `-imported-N`. A importação falha quando o arquivo contém um wallpaper inválido ou ilegível, em vez de criar um perfil apontando para um arquivo inexistente.

Importar e aplicar são etapas separadas: importar adiciona o perfil; selecioná-lo aplica-o. Aplicar um perfil personalizado recarrega as superfícies afetadas da sessão. Excluir o perfil personalizado ativo retorna para `argvus-dark`.

## Modos de layout

Os defaults atuais do Hyprland são:

| Configuração | Sticky | Float |
| --- | ---: | ---: |
| Gap interno da janela | `2` | `10` |
| Gap externo em cada borda | `0` | `18` |
| Arredondamento da janela | `0` | `4` |
| Margem da taskbar/shell | próxima da borda | `18` |

Esses são defaults do modo. Uma seleção explícita de tema redefine os campos do modo (`gaps_in`, todos os gaps externos, margens da taskbar/telemetry, `rounded`, `rounding` e `thickness`) e grava `layout.variant` como `sticky` ou `float`. `waybar_pos`, `taskbar_utility_group`, acentos personalizados e wallpapers personalizados permanecem independentes. Alterações manuais dos campos do modo valem até a próxima seleção explícita de tema.
