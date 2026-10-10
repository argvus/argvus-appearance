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

As preferências lógicas ficam em `$XDG_CONFIG_HOME/argvus/config.json`. Animações usam `effects.animations`. O controle global de Blur é `effects.blur_global_enabled`, e os valores de Blur usam as chaves `effects.blur_*` listadas acima. Estados de ativação e valores de transparência das superfícies usam chaves como `effects.blur_control-center_enabled` e `effects.transparency_control-center_value`. Os valores de transparência são limitados a `0–100`; cada valor de Blur fica limitado à sua própria faixa, e o `argvus-config` recusa gravações fora dela. Estado desativado continua diferente de override ausente.

O percentual antigo `effects.blur_global_value` não é mais lido. Um perfil que ainda o contenha mantém a chave no disco sem efeito, e o Blur usa os padrões acima até que os valores sejam aplicados.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<tema-ativo>.conf` é a projeção única dos efeitos, escrita somente pelo `argvus-config`; o `effects-toggle.sh` é um delegate fino para `argvus-config effects`, sem saída própria, e não é uma segunda fonte de verdade. Defaults específicos do tema só são usados quando o campo canônico está ausente, e um `false` explícito nunca é tratado como ausência. Ao trocar de tema, os overrides canônicos são preservados e as projeções afetadas são recriadas.

Desativar Transparência ou Blur em uma superfície afeta somente aquela superfície; os valores numéricos continuam salvos para quando o recurso for reativado.

## Perfis

A exportação/importação de temas inclui os valores de transparência e blur do tema ativo, junto com os estados de efeitos existentes. Temas inativos não são incluídos no perfil. Os arquivos gerados do Waybar, Quickshell e Hyprland são recriados quando o perfil é aplicado.

As páginas de superfície aplicam o rascunho com o botão `[ Aplicar ]`. O Control Center grava o documento canônico pelo helper de efeitos, deixa o `argvus-config` projetar a árvore de efeitos, recarrega os consumidores afetados e lê novamente o valor efetivo. A exportação/importação inclui o escopo canônico de aparência/efeitos; arquivos gerados são recriados, não importados como fonte de verdade.
