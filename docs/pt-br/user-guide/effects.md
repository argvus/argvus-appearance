---
title: Efeitos
description: Configure animações, intensidade global do blur e efeitos por superfície.
slug: pt/0.4.0/docs/user-guide/appearance/effects
---

**Control Center → Aparência → Efeitos** contém somente **Animações** e **Intensidade do blur**. Os controles de ativação de Transparência e Blur ficam nas páginas de cada superfície.

Os controles das superfícies são independentes. A página de Configuração da Central de Controle possui seu próprio valor de Transparência e controle de ativação do Blur; o blur usa a intensidade global.

A Central de Controle é iniciada pelo Foot com um perfil dedicado gerado em `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. No Foot 1.28, a transparência é projetada para `[colors-dark] alpha` e o controle de Blur para `[colors-dark] blur`; a configuração normal do Foot e o terminal ARGVUS permanecem independentes.

## Transparência

Cada superfície possui um submenu **Transparência**, com seu próprio controle de ativação e valor.

A página **Aparência → Inicializadores** controla os fluxos oficiais baseados em Rofi: launcher principal, seletor de emoji, calculadora, clipboard, cheatsheets e menus Rofi de dispositivos removíveis. O valor de Transparência é o alpha final do fundo; `50` resulta em opacidade aproximada de `0,50`, enquanto texto, ícones e linhas selecionadas permanecem opacos. O controle de Blur habilita a layer `rofi` usando a intensidade global existente.

Cada valor vai de `0%` (opaco) a `100%` (totalmente transparente). Use `+` e `-` em passos de 5% e selecione **Aplicar** na página da superfície. Sair da tela descarta um rascunho não aplicado.

Use `↑` e `↓` para mover entre **Ativar** e **Valor**. Na linha **Valor**, `+` e `-` ajustam o rascunho sem mudar o foco. Pressione `Tab` para abrir **Ações** e ative **\[ Aplicar ]**; `Esc` retorna à página da superfície.

## Blur

Cada superfície possui seu próprio controle de ativação de **Blur**. As surfaces de layer e janela do Hyprland usam uma intensidade global do compositor. Use **Efeitos → Intensidade do blur**, ajuste o rascunho com `+` e `-` em passos de 5% e selecione **Aplicar**. O valor fica em `/effects/blur_global_value` e é compartilhado por toda superfície ativada; não existe slider por superfície.

O mesmo fluxo de teclado vale para Blur: `↑/↓` navega entre as opções, `+/-` ajusta o valor e `Tab` abre **Ações** para aplicar.

O Hyprland expõe o raio e o número de passagens do blur de forma global no compositor, mas não permite um raio de GPU independente em cada regra de layer. O ARGVUS mapeia o valor global diretamente para esses parâmetros; cada superfície apenas entra ou sai do blur global. Alterar o enable de uma superfície não altera a intensidade global.

## Estado canônico e arquivos de compatibilidade

As preferências lógicas ficam em `$XDG_CONFIG_HOME/argvus/config.json`. Animações usam `effects.animations`, enquanto a intensidade do blur usa `effects.blur_global_value`; estados de ativação e valores de transparência das superfícies usam chaves como `effects.blur_control-center_enabled` e `effects.transparency_control-center_value`. O terminal usa o mesmo `effects.blur_global_value`; não existe toggle global de Blur nem intensidade separada para o terminal. Os valores são limitados a `0–100` e estado desativado continua diferente de override ausente.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<tema-ativo>.conf` é a projeção única dos efeitos, escrita somente pelo `argvus-config`; o `effects-toggle.sh` é um delegate fino para `argvus-config effects`, sem saída própria, e não é uma segunda fonte de verdade. Defaults específicos do tema só são usados quando o campo canônico está ausente, e um `false` explícito nunca é tratado como ausência. Ao trocar de tema, os overrides canônicos são preservados e as projeções afetadas são recriadas.

Desativar Transparência ou Blur em uma superfície afeta somente aquela superfície; os valores numéricos continuam salvos para quando o recurso for reativado.

## Perfis

A exportação/importação de temas inclui os valores de transparência e blur do tema ativo, junto com os estados de efeitos existentes. Temas inativos não são incluídos no perfil. Os arquivos gerados do Waybar, Quickshell e Hyprland são recriados quando o perfil é aplicado.

As páginas de superfície aplicam o rascunho com o botão `[ Aplicar ]`. O Control Center grava o documento canônico pelo helper de efeitos, deixa o `argvus-config` projetar a árvore de efeitos, recarrega os consumidores afetados e lê novamente o valor efetivo. A exportação/importação inclui o escopo canônico de aparência/efeitos; arquivos gerados são recriados, não importados como fonte de verdade.
