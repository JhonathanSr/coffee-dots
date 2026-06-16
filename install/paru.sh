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
# ==============================================================================
# EJECUCIÓN DEL MÓDULO
# ==============================================================================
install_aur_packages() {
  printf "%b\n" "${CBL}${BLD}[Coffee-Dots] Limpiando caché e instalando paquetes desde el AUR...${CNC}\n"

  if [ ! -x /usr/bin/paru ]; then
    log_error "Paru no se encuentra instalado en el sistema. Abortando."
    return 1
  fi

  # Lista filtrada: ÚNICAMENTE software exclusivo de AUR
  local AUR_PACKAGES=(
    "gitflow-avh"
    "zen-browser-bin"
    "pritunl-client-bin"
    "visual-studio-code-bin"
  )

  # Ejecución de Paru delegando el logging de errores
  paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"
}

# ==============================================================================
# CONTROL PRINCIPAL
# ==============================================================================
main() {
  install_aur_packages
  printf "\n%b\n" "${CGR}✓ [Fase 2] Paquetes exclusivos de AUR desplegados con éxito.${CNC}"
}

main "$@"
