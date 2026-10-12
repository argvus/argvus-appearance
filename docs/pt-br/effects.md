---
title: Efeitos
description: Configure animações, o blur global do Hyprland e a transparência por superfície.
slug: pt/0.4.0/docs/user-guide/appearance/effects
---

**Control Center → Hyprland** contém **Animações** e **Blur**. Os controles de ativação de Transparência ficam nas páginas de cada superfície.

Os controles das superfícies são independentes. A página de Configuração da Central de Controle possui seu próprio valor de Transparência e controle de ativação do Blur; o blur usa os valores globais de Blur.

A Central de Controle é iniciada pelo Foot com um perfil dedicado gerado em `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. No Foot 1.28, a transparência é projetada para `[colors-dark] alpha` e o controle de Blur para `[colors-dark] blur`; a configuração normal do Foot e o terminal ARGVUS permanecem independentes.

## Transparência

Cada superfície possui um submenu **Transparência**, com seu próprio controle de ativação e valor.

A página **Aparência → Inicializadores** controla os fluxos oficiais baseados em Rofi: launcher principal, seletor de emoji, calculadora, clipboard, cheatsheets e menus Rofi de dispositivos removíveis. O valor de Transparência é o alpha final do fundo; `50` resulta em opacidade aproximada de `0,50`, enquanto texto, ícones e linhas selecionadas permanecem opacos. O controle de Blur habilita a layer `rofi` usando as configurações globais de Blur.

Cada valor vai de `0%` (opaco) a `100%` (totalmente transparente). Use `+` e `-` em passos de 5% e selecione **Aplicar** na página da superfície. Sair da tela descarta um rascunho não aplicado.

Use `↑` e `↓` para mover entre **Ativar** e **Valor**. Na linha **Valor**, `+` e `-` ajustam o rascunho sem mudar o foco. Pressione `Tab` para abrir **Ações** e ative **\[ Aplicar ]**; `Esc` retorna à página da superfície.

## Animações

Abra **Control Center → Hyprland → Animations** (Animações). A página tem a chave **Enable** (Ligar) e uma lista **Options** (Opções) com **Custom curves** (Curvas personalizadas) e cinco categorias. Cada categoria lista as animações dela, e cada animação tem sua própria página com **Style** (Estilo), **Speed** (Velocidade), **Curve** (Curva) e, na abertura e no fechamento de janelas, **Pop-in percentage** (Porcentagem de pop-in). As animações que o Hyprland permite desligar também têm a linha de ativação.

Todos os valores dessas páginas fazem parte de um único rascunho, compartilhado por toda a árvore de Animações. Nada é gravado até selecionar **[ Aplicar ]** na parte de baixo de qualquer uma delas. Navegar entre as páginas mantém o rascunho; sair da página de Animações com um rascunho não aplicado pede confirmação. Aplicar grava os valores alterados em uma única chamada e recarrega o Hyprland. A chave **Enable** do topo é o estado global de animações (`effects.animations`): quando está desligada, todas as animações ficam desativadas, independentemente da chave de cada uma.

Controles: `↑/↓` move entre as linhas; `←/→` (ou `+/-`) altera o valor selecionado e alterna **Style** e **Curve**; `Enter` digita um valor exato de **Speed**, **Pop-in percentage** ou de um parâmetro de curva (valores fora da faixa são recusados), e alterna **Style** e **Curve** para a próxima opção.

### Categorias e animações

| Categoria | Animação | Chave (`effects.animation_<chave>_*`) | Estilo (padrão) | Velocidade | Ligar |
|---|---|---|---|---|---|
| Janelas | Abertura de janelas | `opening` | `popin`, pop-in 87% | 4.1 | — |
| Janelas | Fechamento de janelas | `closing` | `popin`, pop-in 87% | 1.49 | — |
| Janelas | Movimento de janelas | `moving` | — | 4.79 | sim |
| Workspaces | Troca de workspaces | `switching` | `fade` | 1.94 | — |
| Workspaces | Entrada de workspace | `workspace_in` | `fade` | 1.21 | — |
| Workspaces | Saída de workspace | `workspace_out` | `fade` | 1.94 | — |
| Workspaces | Workspaces especiais | `special_workspace` | `slide` | 5 | — |
| Camadas e pop-ups | Superfícies de camada | `layers` | — | 3.81 | sim |
| Camadas e pop-ups | Entrada de camada | `layers_in` | `fade` | 4 | — |
| Camadas e pop-ups | Saída de camada | `layers_out` | `fade` | 1.5 | — |
| Camadas e pop-ups | Fade | `fade` | — | 3.03 | sim |
| Camadas e pop-ups | Fade de entrada | `fade_in` | — | 1.73 | sim |
| Camadas e pop-ups | Fade de saída | `fade_out` | — | 1.46 | sim |
| Bordas e efeitos | Cor da borda | `border` | — | 5.39 | sim |
| Bordas e efeitos | Ângulo do gradiente da borda | `border_angle` | — | 5 | sim |
| Outras animações | Fator de zoom | `zoom` | — | 7 | sim |
| Outras animações | Monitor adicionado | `monitor_added` | — | 5 | sim |

Os padrões das leafs que o Hyprland 0.56.2 traz na configuração padrão (todas as linhas, exceto Workspaces especiais, Ângulo do gradiente da borda e Monitor adicionado) são os valores padrão do Hyprland: velocidades, estilos e curvas. Essas três mantêm os padrões do ARGVUS, porque a configuração padrão do Hyprland não as define.

Cada leaf oferece somente os estilos que o Hyprland 0.56.2 aceita para ela. Abertura e fechamento de janelas oferecem `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` e `gnomed`. Entrada e saída de camada oferecem `slide`, `popin`, `fade`, `slidefade`, `slidevert` e `slidefadevert`. As leafs de workspace (troca, entrada, saída e workspaces especiais) oferecem `slide`, `fade`, `slidefade`, `slidevert` e `slidefadevert`, sem `popin` nem `gnomed`. Um estilo gravado fora da lista da leaf é ignorado e a leaf usa o padrão. Toda animação começa com a curva `default`. Cada página oferece apenas as linhas que a animação suporta. As chaves gravadas são `effects.animation_<chave>_speed`, `_curve`, `_style` (quando oferecida), `_popin` (abertura e fechamento de janelas) e `_enabled` (quando oferecida).

### Curvas

| Curva | Comportamento | Parâmetros (chave → padrão) |
|---|---|---|
| `default` | A curva que o Hyprland 0.56.2 traz para aquela animação (por exemplo `easeOutQuint`, `almostLinear`, `quick`, `linear` ou a spring `easy`). Animações sem curva padrão do Hyprland usam a Bézier padrão do ARGVUS. | Fixa. |
| `bezier` | Movimento suave, que acelera e desacelera, definido por dois pontos de controle. | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Movimento físico com massa, rigidez e amortecimento; pode ultrapassar o destino, com efeito elástico. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | Velocidade constante durante toda a animação, de `(0, 0)` até `(1, 1)`. | Fixa. |
| `ease_out` | Rápida no início e suave no final, de `(0, 0)` até `(0.58, 1)`. | Fixa. |

Em **Custom curves**, cada curva tem a própria página. A Bézier edita os quatro pontos de controle, a Spring edita massa, rigidez e amortecimento, e a Linear e a Ease-out mostram os pontos fixos. Os valores de Bézier e de Spring valem para toda animação que escolher essa curva.

Faixas e passos: **Speed** (Velocidade) 1–10 com decimais (passo 0.1, pois as velocidades padrão do Hyprland são decimais); **Pop-in percentage** 1–100 em números inteiros (passo 5, padrão 87); pontos da Bézier como acima (passo 0.05); massa da Spring 0.5–10 (passo 0.1), rigidez 0.5–2000 (passo 10) e amortecimento 0.5–200 (passo 1).

Não oferecido: o Hyprland 0.56.2 não tem animação separada para redimensionamento de janelas, para pop-ups nem para os ângulos de gradiente de sombra e de brilho, então a página não mostra linhas para eles.

## Blur

O Blur é uma única configuração global do Hyprland, compartilhada por toda superfície que a ativa. Abra **Control Center → Hyprland → Blur**. A página tem o controle **Ligar** e a lista **Valores** com os parâmetros de `decoration:blur` do Hyprland, com os nomes usados pelo Hyprland:

| Linha | Chave de configuração | Padrão | Faixa | Passo de `←/→` |
|---|---|---|---|---|
| Tamanho | `effects.blur_size` | `6` | 1–64 | 1 |
| Passagens | `effects.blur_passes` | `2` | 1–8 | 1 |
| Brilho | `effects.blur_brightness` | `1` | 0–2 | 0,05 |
| Ruído | `effects.blur_noise` | `0,00` | 0–1 | 0,01 |
| Contraste | `effects.blur_contrast` | `0,900000` | 0–2 | 0,05 |
| Vibrância | `effects.blur_vibrancy` | `0,100000` | 0–1 | 0,01 |
| Escurecimento da vibrância | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0,01 |

Use `↑/↓` para navegar, `←/→` (ou `+/-`) para alterar o valor selecionado pelo passo, e `Enter` para digitar um valor exato; valores fora da faixa são recusados. Nada é gravado durante a edição: o controle e os valores permanecem no rascunho até selecionar **[ Aplicar ]** no fim da página. Aplicar grava todos os valores alterados em uma única chamada e depois recarrega o Hyprland. Sair da página com um rascunho não aplicado pede confirmação.

Os valores são enviados ao Hyprland como estão; o ARGVUS não os deriva mais de uma porcentagem. Alterar o controle de uma superfície não altera os valores.

## Estado canônico e arquivos de compatibilidade

As preferências lógicas ficam em `$XDG_CONFIG_HOME/argvus/config.json`. Animações usam `effects.animations`; os valores de Animações usam as chaves `effects.animation_*` descritas acima. O controle global de Blur é `effects.blur_global_enabled`, e os valores de Blur usam as chaves `effects.blur_*` listadas acima. Estados de ativação e valores de transparência das superfícies usam chaves como `effects.blur_control-center_enabled` e `effects.transparency_control-center_value`. Os valores de transparência são limitados a `0–100`; cada valor de Blur fica limitado à sua própria faixa, e o `argvus-config` recusa gravações fora dela. Estado desativado continua diferente de override ausente.

O percentual antigo `effects.blur_global_value` não é mais lido. Um perfil que ainda o contenha mantém a chave no disco sem efeito, e o Blur usa os padrões acima até que os valores sejam aplicados.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<tema-ativo>.conf` é a projeção única dos efeitos, escrita somente pelo `argvus config`; o `effects-toggle.sh` é um delegate fino para `argvus config effects`, sem saída própria, e não é uma segunda fonte de verdade. Defaults específicos do tema só são usados quando o campo canônico está ausente, e um `false` explícito nunca é tratado como ausência. Ao trocar de tema, os overrides canônicos são preservados e as projeções afetadas são recriadas.

Desativar Transparência ou Blur em uma superfície afeta somente aquela superfície; os valores numéricos continuam salvos para quando o recurso for reativado.

## Perfis

A exportação/importação de temas inclui os valores de transparência e blur do tema ativo, junto com os estados de efeitos existentes. Temas inativos não são incluídos no perfil. Os arquivos gerados do Waybar, Quickshell e Hyprland são recriados quando o perfil é aplicado.

As páginas de superfície aplicam o rascunho com o botão `[ Aplicar ]`. O Control Center grava o documento canônico pelo helper de efeitos, deixa o `argvus-config` projetar a árvore de efeitos, recarrega os consumidores afetados e lê novamente o valor efetivo. A exportação/importação inclui o escopo canônico de aparência/efeitos; arquivos gerados são recriados, não importados como fonte de verdade.
