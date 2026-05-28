#!/usr/bin/env bash
# Componente: Gestión de Energía y Monitoreo de Batería (Laptop vs Desktop)

CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); CBL=$(tput setaf 4); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

trap 'printf "%s%sERROR:%s Fallo en gestión de energía (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# 1. Asegurar que el demonio del sistema esté encendido
if systemctl is-sidebar &>/dev/null || [ -f /usr/bin/powerprofilesctl ]; then
  printf "%b\n" "${BLD}${CYE}Activando demonio de perfiles de energía...${CNC}"
  sudo systemctl enable --now power-profiles-daemon.service >/dev/null 2>>"$ERROR_LOG"
else
  printf "%b\n" "${CRE}⚠️ power-profiles-daemon no está instalado. Recuerda listarlo en .install/01-pacman.sh${CNC}"
  exit 0
fi

# 2. Despliegue de Servicios Systemd de Usuario para Laptops
setup_battery_monitor() {
  local user_systemd_dir="${REAL_HOME}/.config/systemd/user"
  printf "%b\n" "${BLD}${CYE}Creando servicios de monitoreo de batería para el usuario...${CNC}"
  mkdir -p "$user_systemd_dir"

  # Inyección del Servicio (Optimizado para Wayland/Hyprland)
  cat <<EOF >"${user_systemd_dir}/battery-monitor.service"
[Unit]
Description=Battery Monitor Check
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=${REAL_HOME}/.config/coffee/bin/battery-monitor
PassEnvironment=DISPLAY WAYLAND_DISPLAY XDG_RUNTIME_DIR

[Install]
WantedBy=default.target
EOF

  # Inyección del Temporizador (Timer)
  cat <<EOF >"${user_systemd_dir}/battery-monitor.timer"
[Unit]
Description=Coffee-Dots Battery Monitor Timer
Requires=battery-monitor.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=30sec
AccuracySec=10sec

[Install]
WantedBy=timers.target
EOF

  # Corregir permisos de propiedad para que pertenezcan al usuario real
  chown -R "${REAL_USER}:${REAL_USER}" "${REAL_HOME}/.config/systemd"

  # Habilitar el timer en el entorno del usuario real usando subshell como el usuario
  printf "%b\n" "${BLD}${CYE}Habilitando temporizador de batería...${CNC}"
  sudo -u "${REAL_USER}" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "${REAL_USER}")/bus" \
    systemctl --user enable --now battery-monitor.timer >/dev/null 2>>"$ERROR_LOG" || log_error "No se pudo activar el timer de usuario"
}

# 3. Lógica de Detección de Hardware e Inyección de Perfiles
if ls /sys/class/power_supply/BAT* &>/dev/null; then
  printf "%b\n" "${BLD}${CBL}💻 Tipo de hardware detectado: Laptop${CNC}"
  
  # Perfil balanceado para cuidar la autonomía de la batería
  powerprofilesctl set balanced || true
  
  # Desplegar y activar el monitor
  setup_battery_monitor
  printf "%b\n" "${CGR}✓ Perfil balanceado y monitor de batería activados.${CNC}"
else
  printf "%b\n" "${BLD}${CBL}🖥️ Tipo de hardware detectado: Desktop (Workstation)${CNC}"
  
  # Perfil de máximo rendimiento para desarrollo pesado y gaming con tu Ryzen/Radeon
  powerprofilesctl set performance || true
  printf "%b\n" "${CGR}✓ Perfil de alto rendimiento ('performance') establecido con éxito.${CNC}"
fi