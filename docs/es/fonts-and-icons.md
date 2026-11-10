---
title: Fuentes e íconos
description: Configure las fuentes y los temas de iconos utilizados por ARGVUS.
---
`argvus-fonts` instala las fuentes incluidas bajo `/usr/share/fonts/`; `argvus-icons` instala los temas de iconos ARGVUS. `argvus-appearance` y el Centro de Control conectan estos recursos con el tema de escritorio.

## Fuente principal

La fuente primaria predeterminada de ARGVUS es **IBM Plex Mono**, con el estilo `Regular`. Es la familia predeterminada utilizada por los objetivos de fuente expuestos en el Centro de Control. El paquete `argvus-fonts` incluido proporciona IBM Plex Mono y las familias de soporte de iconos/terminal utilizadas por el escritorio.

Abra **Centro de Control → Fuentes** para configurar objetivos individuales:

- barra de tareas;
- telemetría/información del sistema;
- Panel de Control;
- interfaz del sistema ARGVUS;
- aplicaciones;
- terminal;
- navegador.

Los tamaños predeterminados son específicos de cada objetivo: la barra de tareas, el sistema y el terminal usan `13`; telemetría y Panel de Control usan `14`; las aplicaciones usan `12`; y el navegador usa `10`. Estos valores predeterminados pueden restaurarse desde la página de Fuentes.

## Tema de iconos

El tema de iconos activo se almacena canónicamente como `appearance.icon_theme` en `config.json`. Un valor vacío (el predeterminado) selecciona el tema de iconos ARGVUS del modo del tema activo: `Argvus Dark Icons` para temas oscuros y `Argvus Light Icons` para temas claros, ambos instalados por `argvus-icons`.

`sh/icon-switch.sh` resuelve el tema efectivo y lo aplica a cada consumidor:

- Configuración de GNOME: `org.gnome.desktop.interface icon-theme`;
- GTK 3 y GTK 4: `gtk-icon-theme-name` en los archivos ARGVUS y `settings.ini` nativos;
- Qt: `icon_theme` en el `qt6ct.conf` gestionado, y en el `qt6ct.conf` nativo cuando fue generado por ARGVUS.

Los temas se buscan en `/usr/share/icons`, `$XDG_DATA_HOME/icons` y `~/.icons`. Un tema configurado que no está instalado, o un valor que contiene `/` o es `..`, vuelve al valor predeterminado del mismo modo y registra un mensaje, por lo que el escritorio nunca apunta a un tema inexistente. Un cambio de tema o de modo utiliza la elección de ícono del perfil de tema exportado cuando está presente, de lo contrario restaura el valor predeterminado del modo empaquetado. Exporte el tema para conservar una elección de ícono personalizada a través de los cambios.

Utilice los controles de fuente en el Centro de Control. Las preferencias de fuente son canónicas en `config.json`, en `fonts.targets.<target>` para familia, estilo y tamaño, además de `fonts.rendering` para antialiasing, hinting, orden de subpíxeles y DPI. El Centro de Control las persiste a través de `argvus-config`; no escribe archivos de consumidor por sí mismo. Luego `argvus-config` proyecta `data/generated/fonts.conf` y reescribe el bloque de fuente delimitado dentro de `data/waybar/argvus-taskbar.css` y `data/waybar/argvus-widget-telemetry.css`, de modo que las ediciones de fuente fuera de esos bloques sobreviven a un cambio de fuente. Las reglas de fontconfig de Terminal y GTK permanecen como objetivos nativos del adaptador. El paquete ejecuta la actualización de la caché de fuentes durante la instalación.

La generación del módulo de la barra de tareas valida el JSONC resultante antes de publicarlo. Las listas del módulo de utilidades se reconstruyen a partir de las preferencias habilitadas, incluyendo un expansor de cajón que solo funciona en modo hover. El modo de icono del espacio de trabajo renderiza `{windows}` junto con `{name}`. La visibilidad de la bandeja del sistema solo afecta a los iconos de aplicaciones en segundo plano.

El proyector del grupo de utilidades conserva custom/ai cuando está habilitado en los módulos opcionales y definido por la plantilla de la barra de tareas. Su glifo nf-md-robot (U+F06A9) abre el menú compartido de agentes de IA; la disponibilidad sigue siendo controlada por el módulo, incluso cuando todos los demás iconos de utilidades están deshabilitados.

La visibilidad del icono de IA se controla mediante /taskbar/icons/ai_agents_enabled (valor predeterminado true), expuesto en Centro de Control > Apariencia > Barra de tareas > Iconos > Módulos opcionales > Agentes de IA. El proyector respeta el estado deshabilitado en cada aplicación y mantiene el grupo de utilidades cuando solo los Agentes de IA están habilitados.

El proyector de la barra de tareas coloca el Estado de Actualización en un grupo separado entre Utilidades y el grupo de red/rendimiento cuando `/taskbar/icons/update_status_enabled` es verdadero. También actualiza configuraciones generadas anteriormente con la definición del módulo.

El auxiliar es `argvus window-mode-menu`; `argvus window-mode-menu --status` emite JSON de Waybar. Se entrega con el paquete maestro `argvus`. Se conservan las copias personalizadas de la barra de tareas existentes: agregue la definición del módulo `custom/window-mode` y la entrada de grupo desde la plantilla empaquetada para optar por ella, o use el Centro de Control. El proyector de apariencia conserva el módulo cuando su definición está presente, incluso si otros iconos de utilidades están deshabilitados.

Los consumidores de temas `window-bar` y `window-controls` obtienen sus colores de bg, fg y acento. Los colores de la barra de título se recargan a través de `argvus windows decorations`; la barra de la ventana sigue su hoja de estilos generada. Tile/Flotante es independiente de la geometría de apariencia Sticky/Spaced.
