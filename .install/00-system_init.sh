#!/usr/bin/env bash

# ==============================================================================
# Fase: 00-system_init | Componente: AUR & Repositorios (coffee-dots)
# ==============================================================================

# Variables globales y de entorno
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"

# Asegurar que las variables de color existan (por si no se heredan)
BLD="${BLD:-$(tput bold)}"
CNC="${CNC:-$(tput sgr0)}"
CRE="${CRE:-$(tput setaf 1)}" # Red
CGR="${CGR:-$(tput setaf 2)}" # Green
CYE="${CYE:-$(tput setaf 3)}" # Yellow
CBL="${CBL:-$(tput setaf 4)}" # Blue

# ------------------------------------------------------------------------------
# Manejo de Errores
# ------------------------------------------------------------------------------
log_error() {
  local error_msg="$1"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  printf "[%s] ERROR: %s\n" "${timestamp}" "${error_msg}" >>"$ERROR_LOG"
  printf "%s%sERROR:%s %s\n" "${CRE}" "${BLD}" "${CNC}" "${error_msg}" >&2
}

# ------------------------------------------------------------------------------
# Configuración de Pacman (Estética)
# ------------------------------------------------------------------------------
setup_pacman_ui() {
  printf "%b\n" "${BLD}${CYE}Configurando estética de pacman.conf...${CNC}"
  
  # Descomentar o agregar Color
  if grep -q "^#Color" /etc/pacman.conf; then
    sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
  elif ! grep -q "^Color" /etc/pacman.conf; then
    sudo sed -i '/^\[options\]/a Color' /etc/pacman.conf
  fi

  # Agregar ILoveCandy si no existe
  if ! grep -q "^ILoveCandy" /etc/pacman.conf; then
    sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
  fi
}

# ------------------------------------------------------------------------------
# Ejecución Principal (Main)
# ------------------------------------------------------------------------------
main() {
  # 1. Ajustes visuales de Pacman
  setup_pacman_ui


  # 3. Sincronizar bases de datos antes de buscar herramientas de espejos
  printf "%b\n" "\n${BLD}${CYE}Sincronizando repositorios...${CNC}"
  sudo pacman -Sy --noconfirm

  # 4. Optimizar espejos (Ahora que CachyOS/Chaotic ya son visibles si aplica)
  printf "%b\n" "\n${BLD}${CYE}Instalando y configurando rate-mirrors...${CNC}"
  if sudo pacman -S --noconfirm --needed cachyos-rate-mirrors rate-mirrors 2>>"$ERROR_LOG"; then
    sudo cachyos-rate-mirrors
  else
    log_error "No se pudo instalar rate-mirrors. Saltando optimización de espejos."
  fi

  # 5. Instalar Paru (Helper de AUR)
  printf "%b\n" "\n${BLD}${CYE}Instalando Paru...${CNC}"
  sudo pacman -S --noconfirm --needed paru

  # 6. Actualización general del sistema final
  printf "%b\n" "\n${BLD}${CYE}Actualizando el sistema completo...${CNC}"
  sudo pacman -Syyu --noconfirm
}

main "$@"