#!/bin/bash

# Colores para mensajes
CRE=$(tput setaf 1) # Red
CYE=$(tput setaf 3) # Yellow
CGR=$(tput setaf 2) # Green
CBL=$(tput setaf 4) # Blue
BLD=$(tput bold)    # Bold
CNC=$(tput sgr0)    # Reset colors

# Variables globales
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"

# Maneja errores
log_error() {
  error_msg=$1
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  printf "%s" "[${timestamp}] ERROR: ${error_msg}\n" >>"$ERROR_LOG"
  printf "%s%sERROR:%s %s\n" "${CRE}" "${BLD}" "${CNC}" "${error_msg}" >&2
}

#Agregando el repositorio de chaotic-aur para instalar paru y otras herramientas útiles
add_chaotic_repo() {
  repo_name="chaotic-aur"
  key_id="3056513887B78AEB"
  sleep 2

  printf "%b\n" "${BLD}${CYE}Instalando ${CBL}${repo_name}${CYE} repositorio...${CNC}"

  if grep -q "\[${repo_name}\]" /etc/pacman.conf; then
    printf "%b\n" "\n${BLD}${CYE} El repositorio ${CBL}${repo_name}${CYE} ya está configurado en pacman.conf${CNC}"
    sleep 3
    return 0
  fi

  if ! pacman-key -l | grep -q "$key_id"; then
    printf "%b\n" "${BLD}${CYE}Agregando llave GPG...${CNC}"
    if ! sudo pacman-key --recv-key "$key_id" --keyserver keyserver.ubuntu.com 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
      log_error "Fallo al agregar la clave GPG"
      return 1
    fi

    printf "%b\n" "${BLD}${CYE}Firmando llave localmente...${CNC}"
    if ! sudo pacman-key --lsign-key "$key_id" 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
      log_error "Fallo al firmar la clave GPG localmente"
      return 1
    fi
  else
    printf "\n%b\n" "${BLD}${CYE}GPG key ya está en el keyring${CNC}"
  fi

  chaotic_pkgs="chaotic-keyring chaotic-mirrorlist"
  for pkg in $chaotic_pkgs; do
    if ! pacman -Qq "$pkg" >/dev/null 2>&1; then
      printf "%b\n" "${BLD}${CYE}Installing ${CBL}${pkg}${CNC}"
      if ! sudo pacman -U --noconfirm "https://cdn-mirror.chaotic.cx/chaotic-aur/${pkg}.pkg.tar.zst" 2>&1 | tee -a "$ERROR_LOG" >/dev/null; then
        log_error "Fallo al instalar ${pkg}"
        return 1
      fi
    else
      printf "%b\n" "${BLD}${CYE}${pkg} ya está instalado${CNC}"
    fi
  done

  printf "\n%b\n" "${BLD}${CYE}agregando a pacman.conf...${CNC}"
  if ! printf "\n[%s]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" "$repo_name" |
    sudo tee -a /etc/pacman.conf >/dev/null 2>>"$ERROR_LOG"; then
    log_error "Fallo al agregar el repositorio a pacman.conf"
    return 1
  fi

  printf "%b\n" "\n${BLD}${CBL}${repo_name} ${CGR}Repositorio configurado correctamente!${CNC}"
  sleep 3
}

# Actualiza los espejos 
sudo pacman -Sy --noconfirm --needed rate-mirrors
sudo cachyos-rate-mirrors

# Instala paru 
sudo pacman -S --noconfirm --needed paru
add_chaotic_repo
sudo pacman -Syyu

# Agrega colores a pacman.conf
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy' /etc/pacman.conf
fi
