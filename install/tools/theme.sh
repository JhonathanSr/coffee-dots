#!/bin/bash

# ==============================================================================
# SCRIPT: Visual Themes & Customization Setup
# DESCRIPCIÓN: Configuración de la apariencia estética del sistema (Rice). 
#              Gestiona motores de temas Qt (Kvantum), GTK, iconos y cursores, 
#              además de sincronizar el esquema de colores entre aplicaciones 
#              como Neovim, Ghostty y BTOP mediante enlaces simbólicos.
# DEPENDENCIAS: sudo pacman, gsettings, kvantum-qt5, gnome-themes-extra.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Gestión de Motores de Temas ---
# Kvantum permite que aplicaciones Qt sigan una estética personalizada.
if ! sudo pacman -Q kvantum-qt5 &>/dev/null; then
  sudo pacman -S --noconfirm kvantum-qt5
fi

# Temas base de GNOME necesarios para aplicaciones GTK en entornos Wayland.
if ! sudo pacman -Q gnome-themes-extra &>/dev/null; then
  sudo pacman -S --noconfirm gnome-themes-extra 
fi

# Iconografía Yaru (Ubuntu style) para un look moderno y pulido.
if ! sudo pacman -Q yaru-icon-theme &>/dev/null; then
  sudo pacman -S --noconfirm yaru-icon-theme
fi

# --- Configuración Global de Interfaz (GSettings) ---
# Establecemos el esquema oscuro y los temas de iconos de forma mandatoria.
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

# --- Despliegue de Activos Visuales ---


# --- Orquestación de Temas Dinámicos (Symlinks) ---
# Creamos una estructura de 'current' para cambiar de tema globalmente con un enlace.
mkdir -p $HOME/.config/themes/current
ln -snf $HOME/coffee-dots/themes/vantablack ~/.config/themes/current/theme
ln -snf $HOME/coffee-dots/themes/backgrounds/back-moon.jpg ~/.config/themes/

# --- Sincronización de Aplicaciones Específicas ---

# Neovim: Enlazamos el plugin de color a la configuración actual.
ln -snf ~/.config/themes/current/theme/neovim.lua ~/.config/nvim/lua/plugins/theme.lua

# BTOP: Aplicamos el esquema de colores para el monitor de recursos.
mkdir -p ~/.config/btop/themes
ln -snf ~/.config/themes/current/theme/btop.theme ~/.config/btop/themes/current.theme

# Mako: Configuración de colores para las notificaciones.
mkdir -p ~/.config/mako
ln -snf ~/.config/themes/current/theme/mako.ini ~/.config/mako/config

# Ghostty: Sincronizamos el tema de la terminal de alto rendimiento.
mkdir -p ~/.config/ghostty/themes
ln -snf ~/.config/themes/current/theme/ghostty.config ~/.config/ghostty/themes/current.config


