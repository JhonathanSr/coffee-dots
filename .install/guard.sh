#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: Pre-flight Safety Guards
# DESCRIPCIÓN: Validaciones críticas de arquitectura, privilegios y estado del
#              sistema para prevenir rupturas en entornos de producción.
# DEPENDENCIAS: bash, pacman, coreutils.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 28/05/2026
# ==============================================================================

# Colores para mensajes (Sincronizados con el ecosistema Coffee-Dots)
CRE=$(tput setaf 1) # Red
CYE=$(tput setaf 3) # Yellow
CGR=$(tput setaf 2) # Green
CBL=$(tput setaf 4) # Blue
BLD=$(tput bold)    # Bold
CNC=$(tput sgr0)    # Reset colors

# Error Handling estricto a nivel modular
set -e

abort() {
  echo -e "\n${CRE}${BLD}[!] Requisito Pre-flight no cumplido: $1${CNC}"
  printf "${CYE}¿Deseas ignorar esta advertencia y continuar bajo tu propio riesgo? (s/N): ${CNC}"
  read -r response
  if [[ ! "$response" =~ ^[sS]$ ]]; then
    echo -e "\n${CRE}[!] Instalación cancelada por el usuario.${CNC}"
    exit 1
  fi
}

# 1. Validar que NO se corra como root directo (Evita romper permisos del HOME)
if [ "$EUID" -eq 0 ]; then
  echo -e "\n${CRE}${BLD}[!] ERROR: No ejecutes este script con 'sudo bash' o como root.${CNC}"
  echo "Por favor, ejecútalo como usuario normal: bash install.sh"
  exit 1
fi

# 2. Validar Arquitectura x86_64
[ "$(uname -m)" != "x86_64" ] && abort "Se requiere arquitectura x86_64."

# 3. Validar Instalación Limpia (Evita colisionar con entornos masivos mas complejos)
pacman -Qe gnome-shell &>/dev/null && abort "Se detectó GNOME instalado en el sistema."
pacman -Qe plasma-desktop &>/dev/null && abort "Se detectó KDE Plasma instalado en el sistema."

echo -e "${CGR}✔ Controles de seguridad (Guards): OK${CNC}"