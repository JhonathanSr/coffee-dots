#!/bin/bash

# ==============================================================================
# SCRIPT: Typography & Iconography Essentials
# DESCRIPCIÓN: Instalación de fuentes tipográficas, glifos de Nerd Fonts y
#              soporte para emojis y caracteres CJK (Chino, Japonés, Coreano).
#              Esencial para la correcta visualización de Waybar y Neovim.
# DEPENDENCIAS: sudo pacman, fontconfig.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Definición de Paquetes Tipográficos ---
# Utilizamos una matriz para organizar las fuentes por categoría.
FONTS=(
  # Iconografía y Glifos (Esencial para Waybar y TUI apps)
  "ttf-font-awesome"
  "ttf-cascadia-mono-nerd"
  
  # Fuentes Monoespaciadas para Desarrollo (Neovim/Ghostty)
  "ttf-jetbrains-mono"
  "ttf-ia-writer"
  
  # Soporte de Texto Internacional y Emojis
  "noto-fonts"
  "noto-fonts-emoji"
  "noto-fonts-cjk"
  "noto-fonts-extra"
  "ttf-dejavu"
  "ttf-liberation"
)

# --- Proceso de Instalación ---
echo "Instalando ecosistema tipográfico..."

# Instalamos la lista completa asegurando que solo se descargue lo necesario.
sudo pacman -S --noconfirm --needed "${FONTS[@]}"

# --- Post-instalación ---
# Refrescamos la caché de fuentes del sistema para que las apps las detecten.
if command -v fc-cache &>/dev/null; then
  fc-cache -fv
fi


