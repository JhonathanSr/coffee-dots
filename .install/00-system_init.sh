#!/bin/bash

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
# Agregar Repositorio Chaotic-AUR
# ------------------------------------------------------------------------------
add_chaotic_repo() {
  local repo_name="chaotic-aur"
  local key_id="3056513887B78AEB"
  local chaotic_pkgs="chaotic-keyring chaotic-mirrorlist"

  printf "%b\n" "${BLD}${CYE}Instalando repositorio ${CBL}${repo_name}${CYE}...${CNC}"
  sleep 1

  if grep -q "\[${repo_name}\]" /etc/pacman.conf; then
    printf "%b\n" "${BLD}${CYE}El repositorio ${CBL}${repo_name}${CYE} ya está configurado.${CNC}"
    return 0
  fi

  # Gestión de Llaves GPG
  if ! sudo pacman-key -l | grep -q "$key_id"; then
    printf "%b\n" "${BLD}${CYE}Agregando y firmando llave GPG...${CNC}"
    if ! sudo pacman-key --recv-key "$key_id" --keyserver keyserver.ubuntu.com 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
      log_error "Fallo al agregar la clave GPG"
      return 1
    fi

    if ! sudo pacman-key --lsign-key "$key_id" 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
      log_error "Fallo al firmar la clave GPG localmente"
      return 1
    fi
  else
    printf "%b\n" "${BLD}${CYE}La llave GPG ya se encuentra en el keyring.${CNC}"
  fi

  # Instalación de Keyring y Mirrorlist de Chaotic
  for pkg in $chaotic_pkgs; do
    if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
      printf "%b\n" "${BLD}${CYE}Instalando ${CBL}${pkg}${CNC}"
      if ! sudo pacman -U --noconfirm "https://cdn-mirror.chaotic.cx/chaotic-aur/${pkg}.pkg.tar.zst" 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
        log_error "Fallo al instalar ${pkg}"
        return 1
      fi
    else
      printf "%b\n" "${BLD}${CYE}${pkg} ya está instalado.${CNC}"
    fi
  done

  # Inserción en pacman.conf
  printf "%b\n" "${BLD}${CYE}Agregando ${repo_name} a pacman.conf...${CNC}"
  if ! printf "\n[%s]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" "$repo_name" |
    sudo tee -a /etc/pacman.conf >/dev/null 2>>"$ERROR_LOG"; then
    log_error "Fallo al agregar el repositorio a pacman.conf"
    return 1
  fi

  printf "%b\n" "${BLD}${CBL}${repo_name} ${CGR}configurado correctamente!${CNC}"
}

# ------------------------------------------------------------------------------
# Ejecución Principal (Main)
# ------------------------------------------------------------------------------
main() {
  # 1. Ajustes visuales de Pacman
  setup_pacman_ui

  # 2. Agregar repositorio externo indispensable primero
  add_chaotic_repo

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