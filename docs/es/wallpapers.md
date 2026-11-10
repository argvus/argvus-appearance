---
title: Fondos de pantalla
description: Usa fondos de pantalla ARGVUS integrados y personalizados.
---
Los fondos de pantalla JPEG XL integrados son instalados por `argvus-wallpapers` bajo `/usr/share/backgrounds/argvus/`. En **Centro de control → Apariencia → Fondos de pantalla**, están organizados como `Abstract` o `Landscape`, luego por `Dark` o `Light`. Los archivos raíz `argvus-dark.jxl` y `argvus-light.jxl` aparecen bajo los grupos de reserva abstractos. El cambio de tema utiliza solo los archivos abstractos en `abstract/dark` y `abstract/light`; los archivos de paisaje son opciones manuales opcionales. Presiona `SUPER + Y` para abrir directamente esta pantalla del Centro de control. La primera entrada también acepta una imagen personalizada desde HOME; el archivo seleccionado se convierte en el estado de fondo de pantalla personalizado del usuario.

La primera entrada abre un selector de archivos para una imagen personalizada. Un fondo de pantalla personalizado seleccionado se guarda como `/appearance/wallpaper` junto con `/appearance/wallpaper_custom` en la configuración canónica, y `argvus config` lo proyecta en la configuración de fondo de pantalla de Hyprland utilizada por la sesión. Permanece activo hasta que un cambio de tema o modo reaplica el fondo de pantalla de ese tema. Exporta el tema activo para incluir el fondo de pantalla actual y conservarlo en el tema exportado. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` es solo una entrada de migración heredada.

Cuando se exporta un tema, la imagen de fondo de pantalla actual se incluye cuando es legible. La importación instala el tema; aplicarlo activa su fondo de pantalla. Vea [Importación y exportación de temas](/docs/components/argvus-themes/import-and-export/).

Los controles de apariencia orientados al usuario utilizan el asistente de Hyprland `hypr-wallpaper-pick.sh`, que confirma la ruta elegida a través de `argvus config` en lugar de almacenar el estado del fondo de pantalla por sí mismo. No edite directamente la configuración del fondo de pantalla generada.
