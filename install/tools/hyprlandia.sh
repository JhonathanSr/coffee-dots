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

# --- Suite Nativa de Hyprland ---
# Instalamos el motor de composición y sus utilidades oficiales.
# hyprshot: Capturas de pantalla | hyprpicker: Selector de color.
# hyprlock/idle: Gestión de sesión y ahorro de energía.
# hyprsunset: Filtro de luz azul (Blue light filter).
paru -S --needed hyprland hyprshot hyprpicker hyprlock hyprlauncher  hypridle hyprsunset hyprland-qtutils hyprland-guiutils hyprland-preview-share-picker

# --- Componentes de Interfaz y Sistema (UI) ---
# polkit-gnome: Gestión de privilegios gráficos (Auth agent).
# rofi: Lanzador de aplicaciones altamente personalizable.
# waybar: Barra de estado altamente modular.
# mako: Demonio de notificaciones ligero.
# swaybg/swayosd: Gestión de fondos de pantalla y OSD (On-Screen Display).
paru -S --noconfirm --needed polkit-gnome libqalculate waybar mako swaybg swayosd libnotify

# --- Portales y Aplicaciones de Base ---
# xdg-desktop-portal-hyprland: Comunicación vital para screen sharing y diálogos.
# calcurse: Calendario y agenda TUI.
# thunar: Gestor de archivos ligero basado en GTK.
paru -S --noconfirm --needed xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt5-wayland kvantum-qt5 gnome-themes-extra yaru-icon-theme
