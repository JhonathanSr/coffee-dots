#!/usr/bin/env bash
# Componente: Optimización de Red, DNS y Tiempos de Arranque

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

# Base paths for the ecosystem
REPO_CONFIG_DIR="${REAL_HOME}/coffee-dots/config"
TARGET_CONFIG_DIR="${REAL_HOME}/.config"
COFFEE_BIN_DIR="${TARGET_CONFIG_DIR}/coffee"


CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); CBL=$(tput setaf 4); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
trap 'printf "%s%sERROR:%s Fallo en optimización de red (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# 1. DNS de Cloudflare
if [ -f "$HOME/coffee-dots/default/systemd/resolved.conf" ]; then
  printf "%b\n" "${BLD}${CYE}Estableciendo DNS estables de Cloudflare...${CNC}"
  sudo cp "$HOME/coffee-dots/default/systemd/resolved.conf" /etc/systemd/
fi

# 2. Remover timeouts molestos
printf "%b\n" "${BLD}${CYE}Removiendo retrasos (wait-online) de red en el arranque...${CNC}"
for service in systemd-networkd-wait-online.service NetworkManager-wait-online.service; do
  if systemctl list-unit-files "$service" >/dev/null 2>&1; then
    sudo systemctl mask "$service" >/dev/null 2>>"$ERROR_LOG"
  fi
done


if [ -f /usr/bin/pacman ]; then
  printf "%b\n" "${BLD}${CYE}Configurando backend de Wi-Fi de alto rendimiento (iwd)...${CNC}"
  
  # 1. Instalar iwd si no existe
  if ! pacman -Qi iwd &>/dev/null; then
    sudo pacman -S --noconfirm iwd >>"$ERROR_LOG" 2>&1
  fi
  
  # 2. Habilitar el servicio
  sudo systemctl enable --now iwd.service >>"$ERROR_LOG" 2>&1

  # 3. Forzar el backend en NetworkManager de forma no interactiva
  sudo mkdir -p /etc/NetworkManager/conf.d
  cat <<EOF | sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf >/dev/null
[device]
wifi.backend=iwd
EOF

  # 4. Reiniciar el servicio en caliente
  sudo systemctl restart NetworkManager.service
  printf "%b\n" "${CGR}✓ Backend iwd configurado y activado con éxito.${CNC}"
fi


if $COFFEE_BIN_DIR/is-battery; then
  cat <<EOF | sudo tee "/etc/udev/rules.d/99-wifi-powersave.rules"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/systemd-run --no-block --collect --unit=wifi-powersave-on $COFFEE_BIN_DIR/wifi-powersave on"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/systemd-run --no-block --collect --unit=wifi-powersave-off $COFFEE_BIN_DIR/wifi-powersave off"
EOF

  sudo udevadm control --reload
  sudo udevadm trigger --subsystem-match=power_supply
fi




printf "%b\n" "${CGR}✓ Optimización de red y boot completada.${CNC}"
