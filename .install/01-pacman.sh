#!/bin/bash

# ==============================================================================
# SCRIPT: Core System & Official Packages Setup
# DESCRIPCIÓN: Instalación de la infraestructura base del sistema, compositor
#              Hyprland, utilidades oficiales, herramientas de compilación,
#              runtimes de desarrollo y paquetes multimedia estables.
# DEPENDENCIAS: pacman, sudo.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 28/05/2026
# ==============================================================================

# Colores para mensajes (Sincronizados con tu install.sh)
CRE=$(tput setaf 1) # Red
CYE=$(tput setaf 3) # Yellow
CGR=$(tput setaf 2) # Green
CBL=$(tput setaf 4) # Blue
BLD=$(tput bold)    # Bold
CNC=$(tput sgr0)    # Reset colors

# Error Handling estricto a nivel modular
set -e

# Manejo de errores local para Pacman
catch_pacman_errors() {
  echo -e "\n${CRE}${BLD}¡La instalación de componentes críticos (Pacman) falló!${CNC}"
  echo "Puedes reintentar este bloque ejecutando de forma aislada:"
  echo "  bash $HOME/coffee-dots/.install/01-pacman.sh"
  echo "Si el error persiste, abre un issue en: https://github.com/JhonathanSr/coffee-dots/issues"
}

trap catch_pacman_errors ERR

echo -e "${CBL}${BLD}[Coffee-Dots] Sincronizando sistema e instalando paquetes oficiales...${CNC}\n"

# Actualización previa de las bases de datos del sistema
sudo pacman -Syu --noconfirm

# Lista consolidada de paquetes de repositorios oficiales
CORE_PACKAGES=(
  # --- Base Gráfica y Core Hyprland ---
  "hyprland"
  "hyprland-guiutils"
  "xdg-desktop-portal-hyprland"
  "xdg-desktop-portal-gtk"
  "qt6-wayland"
  "hyprlock"
  "hypridle"
  "hyprpicker"
  "hyprshot"
  "hyprsunset"
  "hyprpaper"
  "rofi"
  "hyprpolkitagent"
  
  # --- Base de Compilación (Build Essentials) ---
  "gcc"
  "cmake"
  "make"
  "ninja"
  "clang"
  "llvm"
  
  # --- Herramientas de Terminal y Shell ---
  "zsh"
  "yazi"
  "github-cli"
  "lazygit"
  "wget"
  "curl"
  "inetutils"
  "whois"
  "fastfetch"
  "btop"
  "nvtop"
  "man"
  "tldr"
  "less"
  "plocate"
  "chafa"
  "jq"
  "xmlstarlet"
  "imagemagick"
  
  # --- Sistema de Archivos, Compresión y ZFS ---
  "zip"
  "tar"
  "gzip"
  "xz"
  "zstd"
  "cpio"
  
  # --- Multimedia, Audio y Control de Hardware ---
  "mpv"
  "imv"
  "feh"
  "evince"
  "brightnessctl"
  "playerctl"
  "pamixer"
  "wireplumber"
  "pipewire-alsa"
  "pipewire-pulse"
  "libva-utils"
  "ffmpegthumbnailer"
  "nautilus"
  "sushi"
  
  # --- Entrada de Texto y Clipboard ---
  "fcitx5"
  "fcitx5-gtk"
  "fcitx5-configtool"
  "wl-clipboard"
  
  # --- Captura y Grabación de Pantalla ---
  "slurp"
  "grim"
  
  # --- Estética, Iconos y Fuentes Base ---
  "kvantum"
  "gnome-themes-extra"
  "yaru-icon-theme"
  "libnotify"
  "libqalculate"
  "fontconfig"
  "ttf-jetbrains-mono"
  "noto-fonts"
  "noto-fonts-emoji"
  "noto-fonts-cjk"
  "noto-fonts-extra"
)

sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"

# --- Activación de Timers Críticos del Sistema ---
sudo systemctl enable --now plocate-driven-updatedb.timer

echo -e "\n${CGR}Fase de Pacman completada con éxito.${CNC}"