#!/bin/bash

# ==============================================================================
# SCRIPT: Hyprland Ecosystem Setup
# DESCRIPCIÓN: Instalación del compositor Hyprland, herramientas nativas de la
#              suite Hypr (lock, idle, sunset) y componentes esenciales de la
#              interfaz de usuario para Wayland.
# DEPENDENCIAS: paru, wayland, hyprland-protocols.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================
# --- Portales y Aplicaciones de Base ---
# xdg-desktop-portal-hyprland: Comunicación vital para screen sharing y diálogos.
# calcurse: Calendario y agenda TUI.
paru -S --noconfirm --needed xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt6-wayland kvantum-qt6-git gnome-themes-extra yaru-icon-theme

# --- Suite Nativa de Hyprland ---
# Instalamos el motor de composición y sus utilidades oficiales.
# hyprshot: Capturas de pantalla | hyprpicker: Selector de color.
# hyprlock/idle: Gestión de sesión y ahorro de energía.
# hyprsunset: Filtro de luz azul (Blue light filter).
paru -S --needed hyprland hyprshot hyprpicker hyprlock rofi hypridle hyprsunset hyprland-qtutils hyprland-guiutils hyprland-preview-share-picker-git

# --- Componentes de Interfaz y Sistema (UI) ---
# hyprpolkitagent: Gestión de privilegios gráficos (Auth agent).
# waybar: Barra de estado altamente modular.
# mako: Demonio de notificaciones ligero.
# swaybg/swayosd: Gestión de fondos de pantalla y OSD (On-Screen Display).
paru -S --noconfirm --needed hyprpolkitagent libqalculate waybar mako hyprpaper swayosd libnotify impala


