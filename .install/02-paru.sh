#!/bin/bash

# ==============================================================================
# SCRIPT: AUR & User Utilities Setup
# DESCRIPCIÓN: Instalación de herramientas exclusivas del AUR (Repository de la
#              Comunidad), utilidades modernas basadas en Rust, barras de estado,
#              emuladores de terminal de última generación y fuentes tipográficas.
# DEPENDENCIAS: paru.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 28/05/2026
# ==============================================================================

# Colores para mensajes
CRE=$(tput setaf 1) # Red
CYE=$(tput setaf 3) # Yellow
CGR=$(tput setaf 2) # Green
CBL=$(tput setaf 4) # Blue
BLD=$(tput bold)    # Bold
CNC=$(tput sgr0)    # Reset colors

# Error Handling estricto a nivel modular
set -e

# Manejo de errores local para Paru
catch_paru_errors() {
  echo -e "\n${CRE}${BLD}¡La instalación de aplicaciones de usuario (Paru/AUR) falló!${CNC}"
  echo "Puedes reintentar este bloque ejecutando de forma aislada:"
  echo "  bash $HOME/coffee-dots/.install/02-paru.sh"
  echo "Si el error persiste, abre un issue en: https://github.com/JhonathanSr/coffee-dots/issues"
}

trap catch_paru_errors ERR

echo -e "${CBL}${BLD}[Coffee-Dots] Limpiando caché e instalando paquetes desde el AUR...${CNC}\n"

# Limpieza quirúrgica de clones previos corruptos de Paru
rm -rf ~/.cache/paru/clone/*

# Lista consolidada de paquetes AUR
AUR_PACKAGES=(
  # --- Entorno Gráfico Avanzado (User Interface) ---
  "waybar"
  "mako"
  "swayosd"
  "impala"
  
  # --- Terminal, Multiplexor y Core Dev ---
  "ghostty"
  "zellij"
  "mise"
  "lazydocker"
  "gum" 
  "python-terminaltexteffects"
  "tzupdate"
  "uwsm"
  
  # --- Utilidades CLI Modernas (Rust-based) ---
  "fd"
  "eza"
  "fzf"
  "ripgrep"
  "zoxide"
  
  # --- Aplicaciones de Escritorio y Productividad ---
  "zen-browser-bin"
  "localsend"
  "obsidian"
  "satty"
  "wl-screenrec"
  
  # --- Hardware, Comunicaciones y Teclado ---
  "bluetui"
  "xremap-hypr-bin"
  
  # --- Estética y Tipografías de AUR ---
  "yaru-gtk-theme"
  "kvantum-theme-materia"
  "ttf-cascadia-mono-nerd"
  "ttf-ia-writer"
  
  # --- Compresores específicos obsoletos/AUR ---
  "7zip"
  "bzip3"
  "arj"
)

paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo -e "\n${CGR}Fase de Paru completada con éxito.${CNC}"