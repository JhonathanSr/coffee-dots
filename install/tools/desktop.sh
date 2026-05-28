#!/bin/bash

# ==============================================================================
# SCRIPT: Desktop Essentials & Graphics Setup
# DESCRIPCIÓN: Instalación de drivers Vulkan, utilidades multimedia, gestión
#              de audio (Pipewire), herramientas de captura y paquetes de gaming.
# DEPENDENCIAS: paru, vulkan-drivers, pipewire, wl-roots tools.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Soporte Gráfico (Vulkan) ---
# Vital para el rendimiento en juegos y aceleración por hardware en aplicaciones.
# Incluye el loader y capas de validación necesarias para el soporte gráfico completo.
paru -S --noconfirm --needed vulkan-icd-loader

# --- Multimedia y Visualización ---
# mpv/imv/feh: Visores ligeros y potentes para video e imágenes.
# LocalSend: Transferencia de archivos en red local.
# Evince: Visor de documentos PDF.
paru -S --noconfirm --needed mpv imv feh localsend evince 

# --- Control de Audio y Sistema ---
# Herramientas esenciales para los keybindings de Hyprland:
# brightnessctl: Control de brillo de monitor/laptop.
# playerctl: Control de medios (Play/Pause/Next) via MPRIS.
# pamixer/wireplumber: Gestión avanzada de audio sobre Pipewire.
paru -S --noconfirm --needed brightnessctl playerctl pamixer wiremix wireplumber pipewire-alsa pipewire-pulse

# --- Entrada de Texto y Clipboard ---
# fcitx5: Framework de entrada (esencial para carácteres especiales o idiomas).
# wl-clip-persist: Mantiene el historial del portapapeles incluso al cerrar apps en Wayland.
paru -S --noconfirm --needed fcitx5 fcitx5-gtk fcitx5-configtool wl-clipboard wl-clipboard

# --- Captura y Grabación de Pantalla ---
# grim/slurp: Base para capturas de pantalla en Wayland.
# satty: Herramienta de anotación para capturas.
# wl-screenrec: Grabación de pantalla eficiente.
paru -S --noconfirm --needed slurp grim satty wl-screenrec

# --- Utilidades de Sistema y Escritorio ---
# libva-utils: Verificación de aceleración de video.
# ffmpegthumbnailer: Generación de miniaturas en gestores de archivos.
paru -S --noconfirm --needed libva-utils ffmpegthumbnailer nautilus nautilus-python sushi obsidian

# --- Navegación Web ---
# Zen Browser: Navegador basado en Firefox optimizado para privacidad y estética.
paru -S --noconfirm --needed zen-browser-bin

# --- Ecosistema Gaming y Seguridad ---
# portproton: Capa de compatibilidad optimizada para juegos de Windows.
# gamemode/gamescope: Optimizadores de rendimiento de Feral e Valve.
# bitwarden: Gestión segura de contraseñas.
paru -S --needed cachyos-gaming-applications protonup-qt vkbasalt bitwarden
