#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: AUR & User Utilities Setup
# DESCRIPCIÓN: Instalación de herramientas exclusivas del AUR (Repository de la
#              Comunidad), utilidades de última generación y fuentes.
# DEPENDENCIAS: paru.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 29/05/2026
# ==============================================================================

# Colores para mensajes (Sincronizados con el ecosistema Coffee-Dots)
CRE=$(tput setaf 1) # Red
CYE=$(tput setaf 3) # Yellow
CGR=$(tput setaf 2) # Green
CBL=$(tput setaf 4) # Blue
BLD=$(tput bold)    # Bold
CNC=$(tput sgr0)    # Reset colors

ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"

# --- Manejo Quirúrgico de Errores ---
log_error() {
  local error_msg="$1"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  printf "[%s] ERROR (Fase 02-Paru): %s\n" "${timestamp}" "${error_msg}" >>"$ERROR_LOG"
  printf "%s%sERROR:%s %s\n" "${CRE}" "${BLD}" "${CNC}" "${error_msg}" >&2
}

catch_paru_errors() {
  log_error "La instalación de aplicaciones de usuario (Paru/AUR) falló en la línea $LINENO."
  printf "\n%s%sPuedes reintentar este bloque de forma aislada ejecutando:%s\n" "${CYE}" "${BLD}" "${CNC}"
  printf "  bash $HOME/coffee-dots/.install/02-paru.sh\n\n"
}

trap catch_paru_errors ERR

# ==============================================================================
# EJECUCIÓN DEL MÓDULO
# ==============================================================================
install_aur_packages() {
  printf "%b\n" "${CBL}${BLD}[Coffee-Dots] Limpiando caché e instalando paquetes desde el AUR...${CNC}\n"

  if [ ! -x /usr/bin/paru ]; then
    log_error "Paru no se encuentra instalado en el sistema. Abortando."
    return 1
  fi

  # Limpieza de clones previos corruptos de Paru
  rm -rf ~/.cache/paru/clone/*

  # Lista filtrada: ÚNICAMENTE software exclusivo de AUR
  local AUR_PACKAGES=(
    # --- Terminal, Multiplexor y Core Dev ---
    "ghostty"
    "zellij"
    "mise"
    "lazydocker"
    "python-terminaltexteffects"

    # --- Aplicaciones de Escritorio y Productividad ---
    "zen-browser-bin"
    "localsend"
    "obsidian"
    "satty"
    "wl-screenrec"

    # --- Hardware, Comunicaciones y Teclado ---a
    "impala" # Gestión WiFi TUI
    "bluetui"
    "xremap-hypr-bin"

    # --- Estética y Tipografías de AUR ---
    "nwg-look-flatpak-git"
    "gtk-engine-murrine"
    "yaru-gtk-theme"
    "kvantum-theme-materia"
    "ttf-cascadia-mono-nerd"
    "ttf-ia-writer"

    # --- Compresores específicos---
    "7zip"

    "inotify-tools"
    "gitflow-avh"
    "hyprland-share-picker"
    "bibata-cursor-git"
    "visual-studio-code-bin"
    "elephant"
    "elephant-providerlist" 
    "elephant-desktopapplications"
  )

  # Ejecución de Paru delegando el logging de errores
  paru -S --needed "${AUR_PACKAGES[@]}" 2>>"$ERROR_LOG"
}

# ==============================================================================
# CONTROL PRINCIPAL
# ==============================================================================
main() {
  install_aur_packages
  printf "\n%b\n" "${CGR}✓ [Fase 2] Paquetes exclusivos de AUR desplegados con éxito.${CNC}"
}

main "$@"
