#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Componente: Gestión de Energía y Automatización de Perfiles (Laptop vs Desktop)
# Ecosistema: coffee-dots ☕
# -----------------------------------------------------------------------------

CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); CBL=$(tput setaf 4); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

COFFEE_BIN_DIR="${REAL_HOME}/.config/coffee"

trap 'printf "%s%sERROR:%s Fallo en gestión de energía (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# 1. Validar e iniciar el demonio del sistema de forma defensiva
if [ -f /usr/bin/powerprofilesctl ]; then
  printf "%b\n" "${BLD}${CYE}Activando demonio de perfiles de energía (power-profiles-daemon)...${CNC}"
  sudo systemctl enable --now power-profiles-daemon.service >/dev/null 2>>"$ERROR_LOG"
else
  printf "%b\n" "${CRE}⚠️ power-profiles-daemon no está instalado. Recuerda listarlo en .install/01-pacman.sh${CNC}"
  exit 0
fi

# 2. Lógica de Detección de Hardware y Configuración de Reglas
if ls /sys/class/power_supply/BAT* &>/dev/null; then
  printf "%b\n" "${BLD}${CBL}💻 Tipo de hardware detectado: Laptop${CNC}"
  
  # Perfil inicial seguro para cuidar la autonomía al arrancar
  powerprofilesctl set balanced || true
  
  # Inyección de reglas de udev unificadas (Llaman a tus binarios de coffee-dots)
  printf "%b\n" "${BLD}${CYE}Escribiendo reglas de udev para automatización en caliente...${CNC}"
  cat <<EOF | sudo tee "/etc/udev/rules.d/99-power-profile.rules" >/dev/null
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="/usr/bin/systemd-run --no-block --collect --unit=coffee-power-profile --property=After=power-profiles-daemon.service ${COFFEE_BIN_DIR}/set-power-profile ac"
SUBSYSTEM=="power_supply", ATTR{type}=="USB", RUN+="/usr/bin/systemd-run --no-block --collect --unit=coffee-power-profile --property=After=power-profiles-daemon.service ${COFFEE_BIN_DIR}/set-power-profile battery"
EOF

  # Aplicar reglas en caliente inmediatamente
  sudo udevadm control --reload 2>/dev/null
  sudo udevadm trigger --subsystem-match=power_supply 2>/dev/null
  
  printf "%b\n" "${CGR}✓ Reglas de udev creadas y aplicadas de forma asíncrona.${CNC}"
  printf "%b\n" "${CGR}✓ Perfil balanceado asignado al inicio.${CNC}"
else
  printf "%b\n" "${BLD}${CBL}🖥️ Tipo de hardware detectado: Desktop (Workstation)${CNC}"
  
  # Limpieza defensiva: Si antes era una laptop o usas el mismo repo en varias máquinas, removemos la regla
  if [ -f "/etc/udev/rules.d/99-power-profile.rules" ]; then
    sudo rm -f "/etc/udev/rules.d/99-power-profile.rules"
  fi
  
  # Máxima potencia para tu Ryzen/Radeon en tu Desktop
  powerprofilesctl set performance || true
  printf "%b\n" "${CGR}✓ Perfil de alto rendimiento ('performance') establecido con éxito.${CNC}"
fi