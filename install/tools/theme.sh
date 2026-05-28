#!/bin/bash

# ==============================================================================
# SCRIPT: Visual Themes & Customization Setup
# DESCRIPCIÓN: Configuración de la apariencia estética del sistema (Rice). 
#              Gestiona motores de temas Qt (Kvantum), GTK, iconos y cursores, 
#              además de sincronizar el esquema de colores entre aplicaciones 
#              como Neovim, Ghostty y BTOP mediante enlaces simbólicos.
# DEPENDENCIAS: paru, gsettings, kvantum-qt5, gnome-themes-extra.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Gestión de Motores de Temas ---
# Kvantum permite que aplicaciones Qt sigan una estética personalizada.
if ! paru -Q kvantum-qt6 &>/dev/null; then
  paru -S --noconfirm kvantum-qt6
fi

# Temas base de GNOME necesarios para aplicaciones GTK en entornos Wayland.
if ! paru -Q gnome-themes-extra &>/dev/null; then
  paru -S --noconfirm gnome-themes-extra 
fi

# Iconografía Yaru (Ubuntu style) para un look moderno y pulido.
if ! paru -Q yaru-icon-theme &>/dev/null; then
  paru -S --noconfirm yaru-icon-theme
fi

# --- Configuración Global de Interfaz (GSettings) ---
# Establecemos el esquema oscuro y los temas de iconos de forma mandatoria.
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

