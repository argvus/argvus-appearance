---
title: Efectos
description: Configura animaciones, el desenfoque global de Hyprland y la transparencia por superficie.
---
**Centro de Control → Hyprland** contiene **Animaciones**, **Desenfoque** y **Bordes**, cuya página **Sombra** controla la sombra de la ventana. Los interruptores de activación de transparencia son configuraciones por superficie en sus respectivas páginas de Apariencia.

Los interruptores de superficie son independientes. La página de Configuración del Centro de Control tiene su propio valor de Transparencia y un interruptor de activación de Desenfoque; su desenfoque usa los valores globales de Desenfoque.

El Centro de Control se inicia a través de Foot con un perfil generado dedicado en `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. Con Foot 1.28, la transparencia se proyecta a `[colors-dark] alpha` y el interruptor de superficie de Desenfoque a `[colors-dark] blur`; la configuración normal de Foot y la terminal ARGVUS permanecen independientes.

## Interruptores de Animaciones y Efectos

Hay dos interruptores maestros independientes, ambos aplicados a `hyprland.lua` a través de la configuración canónica `/effects`:

- **Animaciones** (`/effects/animations`) controla todo lo que se mueve: animaciones del espacio de trabajo, ventana, desvanecimiento, borde y capa.
- **Efectos** es un acceso directo para el desenfoque (`/effects/blur_global_enabled`) y la transparencia del Terminal, Lanzador, Widget de Telemetría, Panel de Control y Barra de Tareas (`/effects/transparency_<surface>_enabled`). Activarlo o desactivarlo aplica todos ellos (y también la transparencia del Centro de Control). Cada superficie mantiene su propia página de transparencia, por lo que Efectos se muestra como **activado cuando al menos uno de ellos está activado** y como desactivado solo cuando todos están desactivados.

Usa `argvus effects-toggle animations status|enable|disable|toggle` y `argvus effects-toggle effects status|enable|disable|toggle`. La tarjeta de Apariencia del Panel de Control muestra un interruptor para cada uno. Apagar un interruptor maestro conserva todos los ajustes finos de las páginas de **Animaciones** y **Desenfoque** (velocidades, curvas, interruptores individuales, tamaño y repeticiones del desenfoque), por lo que encenderlo de nuevo restaura el mismo aspecto. `effects status` imprime `enabled` cuando el desenfoque o al menos una de esas superficies de transparencia está habilitada. Apagar la transparencia de una superficie hace que toda la superficie de Waybar sea opaca: además del fondo, los bordes translúcidos de la barra de tareas y la Telemetría de Widgets se convierten en el color sólido que muestran sobre el fondo del tema. Todos los efectos están habilitados por defecto en una instalación nueva, incluyendo en máquinas virtuales y sesiones de bajo consumo; solo un ajuste explícito apaga uno.

## Todos los efectos a la vez

`argvus effects-toggle` sin un componente actúa sobre animaciones, desenfoque y transparencia juntos: `status` imprime `enabled` solo cuando los tres están habilitados, `enable` y `disable` cambian los tres, y `toggle` apaga todo cuando `status` es `enabled` y lo enciende de otra manera. **SUPER + F6** ejecuta este interruptor. Para actuar sobre un solo grupo, asígnale un nombre: `argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`. La página **Animaciones** del Centro de Control usa la forma por componente, así que su interruptor **Activar** aún cambia solo las animaciones.

## Transparencia

Cada superficie tiene su propio submenú de **Transparencia** con un interruptor de activación y un valor.

La página **Apariencia → Lanzadores** controla el lanzador oficial basado en Rofi y los flujos de selección: el lanzador principal, el selector de emojis, la calculadora, el selector de portapapeles, hojas de trucos y los menús de dispositivos extraíbles de Rofi. Su valor de Transparencia es el alfa de fondo final, por lo que `50` significa una opacidad de fondo efectiva de aproximadamente `0.50`; el texto, los íconos y las filas seleccionadas permanecen opacos. Con la Transparencia desactivada, el lanzador usa el color de fondo del tema activo, completamente opaco. El interruptor de Desenfoque aplica la capa `rofi` en la configuración global de Desenfoque.

Cada valor varía desde `0%` (opaco) hasta `100%` (totalmente transparente). Usa `+` y `-` en incrementos del 5%, y luego selecciona **Aplicar** en la página de superficie. Salir de la página descarta un borrador no aplicado.

Usa `↑` y `↓` para moverte entre **Activar** y **Valor**. En la fila **Valor**, `+` y `-` ajustan el borrador sin cambiar el enfoque. Presiona `Tab` para abrir **Acciones**, luego activa **[ Aplicar ]**; `Esc` vuelve a la página de superficie principal.

## Animaciones

Abre **Centro de Control → Hyprland → Animaciones**. La página tiene un interruptor **Activar** y una lista de **Opciones** con **Curvas personalizadas** y cinco categorías. Cada categoría enumera sus animaciones, y cada animación tiene su propia página con **Estilo**, **Velocidad**, **Curva** y, para la apertura y cierre de ventanas, **Porcentaje de aparición**. Las animaciones que Hyprland puede desactivar también tienen una fila **Activar**.

Cada valor en estas páginas pertenece a un borrador compartido por todo el árbol de Animaciones. Nada se escribe hasta que se selecciona **[ Aplicar ]** en la parte inferior de cualquiera de ellos. Moverse entre las páginas mantiene el borrador; salir de la página de Animaciones con un borrador no aplicado solicita confirmación. Aplicar escribe los valores cambiados en una sola llamada y recarga Hyprland. El interruptor **Habilitar** en la parte superior es el estado global de la animación (`effects.animations`): cuando está apagado, todas las animaciones están deshabilitadas, sin importar lo que diga su propio interruptor.

Controles: `↑/↓` se mueve entre filas; `←/→` (o `+/-`) cambia el valor seleccionado y cicla **Estilo** y **Curva**; `Enter` escribe un **Velocidad**, **Porcentaje de aparición** o parámetro de curva exacto (se rechazan valores fuera de rango), y cicla **Estilo** y **Curva** hacia adelante.

### Categorías y animaciones

| Categoría | Animación | Tecla (`effects.animation_<key>_*`) | Estilo (predeterminado) | Velocidad | Habilitar |
|---|---|---|---|---|---|
| Ventanas | Apertura de ventanas | `opening` | `popin`, entrada emergente 87% | 4.1 | — |
| Ventanas | Cierre de ventanas | `closing` | `popin`, entrada emergente 87% | 1,49 | — |
| Ventanas | Ventanas móviles | `moving` | — | 4,79 | si |
| Espacios de trabajo | Cambiar de espacio de trabajo | `switching` | `fade` | 1,94 | — |
| Espacios de trabajo | Entrada al espacio de trabajo | `workspace_in` | `fade` | 1.21 | — |
| Espacios de trabajo | Salida del espacio de trabajo | `workspace_out` | `fade` | 1,94 | — |
| Espacios de trabajo | Espacios de trabajo especiales | `special_workspace` | `slide` | 5 | — |
| Capas y ventanas emergentes | Superficies de capa | `layers` | — | 3,81 | si |
| Capas y ventanas emergentes | Entrada de capa | `layers_in` | `fade` | 4 | — |
| Capas y ventanas emergentes | Salida de capa | `layers_out` | `fade` | 1.5 | — |
| Capas y ventanas emergentes | Desvanecerse | `fade` | — | 3.03 | si |
| Capas y ventanas emergentes | Fundido en | `fade_in` | — | 1,73 | si |
| Capas y ventanas emergentes | Desaparecer | `fade_out` | — | 1,46 | si |
| Bordes y efectos | Color del borde | `border` | — | 5.39 | si |
| Bordes y efectos | Ángulo del degradado del borde | `border_angle` | — | 5 | sí |
| Otras animaciones | Factor de zoom | `zoom` | — | 7 | sí |
| Otras animaciones | Monitor añadido | `monitor_added` | — | 5 | sí |

Los valores predeterminados de las hojas que Hyprland 0.56.2 incluye en su configuración estándar (todas las filas excepto Espacios de trabajo especiales, Ángulo del degradado del borde y Monitor añadido) son las velocidades, estilos y curvas predeterminadas. Esos tres mantienen los valores predeterminados de ARGVUS, porque la configuración estándar no los define.

Cada hoja ofrece solo los estilos que Hyprland 0.56.2 acepta para ella. La apertura y cierre de ventanas ofrece `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` y `gnomed`. La entrada y salida de capas ofrece `slide`, `popin`, `fade`, `slidefade`, `slidevert` y `slidefadevert`. Las hojas de espacios de trabajo (cambio, entrada, salida y espacios de trabajo especiales) ofrecen `slide`, `fade`, `slidefade`, `slidevert` y `slidefadevert`, sin `popin` o `gnomed`. Un estilo almacenado fuera de la lista de su hoja se ignora y la hoja usa su valor predeterminado. Cada animación comienza con la curva `default`. Una página solo ofrece las filas que su animación admite. Las claves almacenadas son `effects.animation_<key>_speed`, `_curve`, `_style` (donde se ofrezca), `_popin` (apertura y cierre de ventanas) y `_enabled` (donde se ofrezca).

### Curvas

| Curva | Comportamiento | Parámetros (clave → valor predeterminado) |
|---|---|---|
| `default` | La curva que Hyprland 0.56.2 incluye para esa animación (por ejemplo `easeOutQuint`, `almostLinear`, `quick`, `linear` o el resorte `easy`). Las animaciones sin una curva predeterminada usan Bézier incorporada de ARGVUS. | Fijo. |
| `bezier` | Movimiento suave que acelera y desacelera, moldeado por dos puntos de control. | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Movimiento físico con masa, rigidez y amortiguamiento; puede sobrepasar para un efecto elástico. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | Velocidad constante durante toda la animación, desde `(0, 0)` hasta `(1, 1)`. | Fijo. |
| `ease_out` | Rápido al inicio y suave al final, desde `(0, 0)` hasta `(0.58, 1)`. | Fijo. |

Bajo **Curvas personalizadas**, cada curva tiene su propia página. Bézier edita sus cuatro puntos de control, Spring edita la masa, la rigidez y la amortiguación, y Linear y Ease-out muestran sus puntos fijos. Los valores de Bézier y Spring se aplican a cada animación que selecciona esa curva.

Rangos y pasos: **Velocidad** 1–10 con decimales (paso 0.1, las velocidades predeterminadas son decimales); **Porcentaje de aparición** 1–100 en números enteros (paso 5, predeterminado 87); puntos Bézier como se indicó (paso 0.05); masa Spring 0.5–10 (paso 0.1), rigidez 0.5–2000 (paso 10) y amortiguación 0.5–200 (paso 1).

No ofrecido: Hyprland 0.56.2 no tiene animación separada para cambiar el tamaño de las ventanas, para ventanas emergentes, ni para los ángulos de degradado de sombra y brillo, por lo que la página no muestra filas para ellos.

## Desenfoque

El desenfoque es una configuración global de Hyprland, compartida por cada superficie que elija participar. Abre **Centro de Control → Hyprland → Desenfoque**. La página tiene un interruptor **Habilitar** y una lista de **Valores** con los parámetros de `decoration:blur` de Hyprland, bajo los nombres que Hyprland utiliza:

| Fila | Clave de configuración | Predeterminado | Rango | Paso `←/→` |
|---|---|---|---|---|
| Tamaño | `effects.blur_size` | `6` | 1–64 | 1 |
| Pasadas | `effects.blur_passes` | `2` | 1–8 | 1 |
| Brillo | `effects.blur_brightness` | `1` | 0–2 | 0.05 |
| Ruido | `effects.blur_noise` | `0.00` | 0–1 | 0.01 |
| Contraste | `effects.blur_contrast` | `0.900000` | 0–2 | 0.05 |
| Intensidad | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0.01 |
| Oscuridad de la intensidad | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0.01 |

Usa `↑/↓` para mover, `←/→` (o `+/-`) para cambiar el valor seleccionado según su paso, y `Enter` para escribir un valor exacto; los valores fuera del rango son rechazados. Nada se escribe mientras editas: el interruptor y los valores permanecen en borrador hasta que se selecciona **[ Aplicar ]** en la parte inferior de la página. Aplicar escribe todos los valores cambiados en una sola llamada y recarga Hyprland después de ello. Salir de la página con un borrador sin aplicar solicita confirmación.

Los valores se pasan a Hyprland tal como están; ARGVUS no los deriva de un porcentaje. Cambiar el interruptor de una superficie no cambia los valores.

## Sombra

La sombra de la ventana es una configuración global de Hyprland, bajo **Centro de Control → Hyprland → Bordes → Sombra**. Es independiente de la transparencia y el desenfoque: está desactivada por defecto y activar o desactivar la transparencia de una superficie no la cambia.

| Fila | Clave de configuración | Predeterminado | Rango | Paso `←/→` |
|---|---|---|---|---|
| Activar | `effects.shadow_enabled` | `false` | — | — |
| Nitidez | `effects.shadow_sharp` | `false` | — | — |
| Color | `effects.shadow_color` | vacío (sigue el acento) | vacío o `RRGGBBAA` | — |
| Rango | `effects.shadow_range` | `6` | 0–100 | 1 |
| Potencia de renderizado | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| Desplazamiento X | `effects.shadow_offset_x` | `0` | −100 a 100 | 1 |
| Desplazamiento Y | `effects.shadow_offset_y` | `0` | −100 a 100 | 1 |
| Escala | `effects.shadow_scale` | `1.00` | 0–1 | 0.05 |

Un color vacío sigue el acento del tema activo con alfa `99`, así que el acento azul predeterminado da `3590bd99`. Escriba ocho dígitos hexadecimales (`RRGGBBAA`) para fijar el color, o deje el campo vacío para seguir el acento nuevamente. El color se lee cuando se carga la configuración de Hyprland, así que después de un cambio de tema o acento, toma el nuevo acento en la siguiente recarga de configuración.

Al igual que Blur, la página edita un borrador: nada se escribe hasta que se selecciona **[ Aplicar ]**, y salir de la página con un borrador no aplicado solicita confirmación.

## Estado canónico y archivos de compatibilidad

La preferencia lógica se almacena en `$XDG_CONFIG_HOME/argvus/config.json`. La animación global usa `effects.animations`; los valores de Animations usan las claves `effects.animation_*` descritas arriba. El interruptor global de Desenfoque es `effects.blur_global_enabled`, y los valores de Desenfoque usan las claves `effects.blur_*` listadas arriba. Los estados de activación de superficie y los valores de transparencia usan claves como `effects.blur_control-center_enabled` y `effects.transparency_control-center_value`. Los valores de transparencia están limitados a `0–100`; cada valor de Desenfoque está limitado a su propio rango, y `argvus-config` rechaza escrituras fuera de él. Los estados de activación permanecen distintos de las anulaciones faltantes.

El antiguo porcentaje `effects.blur_global_value` ya no se lee. Un perfil que todavía lo contiene mantiene la clave en el disco sin efecto, y Desenfoque usa los valores predeterminados indicados arriba hasta que se aplican sus valores.

```text
$XDG_CONFIG_HOME/argvus/config.json
```
`data/generated/effects/<active-theme>.conf` es la proyección de efectos, escrita solo por `argvus config`; `argvus effects-toggle` delega a `argvus config effects`. Un cambio de tema o de modo reaplica el perfil visual exportado del tema activo, incluidos los valores por superficie de `effects.conf` cuando están presentes. Los temas sin un perfil restauran los valores predeterminados del efecto empaquetado. Exporta el tema después de cambiar los efectos si quieres que esos valores se conserven al cambiar a otro tema o modo.

Deshabilitar el interruptor de Transparencia o Desenfoque de una superficie afecta solo a esa superficie; los valores numéricos guardados se conservan para reactivarlos más tarde.

## Perfiles

La exportación del tema incluye la configuración canónica de apariencia/efectos y la proyección de efectos por superficie del tema activo. Los archivos de tiempo de ejecución generados de Waybar, Quickshell y Hyprland se regeneran cuando se aplica el tema.

Todas las páginas de superficie aplican sus borradores junto con el botón `[ Apply ]`. El Centro de Control escribe el documento canónico a través del asistente de efectos, permite que `argvus-config` proyecte el árbol de efectos, recarga a los consumidores afectados y lee el valor efectivo de nuevo. Los archivos generados se recrean en lugar de importarse como estado autorizado.

## Luz Nocturna

**SUPER + Shift + B** mantiene el selector de brillo y agrega un interruptor separado de Luz Nocturna con estado/temperatura efectivo. Llama a `argvus config display night-light status|toggle`. La Luz Nocturna requiere Hyprland y un Hyprsunset >= 0.4.0 que responda, independientemente del soporte de brillo. El rango es de 1000–20000 K; la configuración se encuentra en **Escritorio y Entrada > Pantallas > Luz Nocturna** en el Centro de Control. Un interruptor es persistente sin programación, o una anulación volátil hasta la próxima transición con programación. Cancelar el menú no cambia nada.
