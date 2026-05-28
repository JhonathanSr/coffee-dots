#!/usr/bin/env bash
# Componente: Autologin de TTY1 Integrado con UWSM para Hyprland

CRE=$(tput setaf 1); 
CYE=$(tput setaf 3); 
CGR=$(tput setaf 2); 
BLD=$(tput bold); 
CNC=$(tput sgr0)

ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
trap 'printf "%s%sERROR:%s Fallo en setup de Autologin UWSM (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

if ! command -v uwsm &>/dev/null; then
  printf "%b\n" "${CRE}⚠️ UWSM no está instalado. Saltando configuración de autologin.${CNC}"
  exit 0
fi

printf "%b\n" "${BLD}${CYE}Configurando Autologin en getty@tty1 para el usuario ${REAL_USER}...${CNC}"
local override_dir="/etc/systemd/system/getty@tty1.service.d"
sudo mkdir -p "$override_dir"

sudo tee "${override_dir}/autologin.conf" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${REAL_USER} --noclear %I \$TERM
Type=idle
EOF

local zprofile_target="$HOME/.zprofile"
if ! grep -q "uwsm check profile" "${zprofile_target}" 2>/dev/null; then
  printf "%b\n" "${BLD}${CYE}Inyectando trigger de UWSM en .zprofile...${CNC}"
  cat <<'EOF' >>"${zprofile_target}"

export ZDOTDIR="$HOME/.config/zsh"

# [Coffee-Dots] Arranque automático de Hyprland vía UWSM en TTY1
if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
    if uwsm check profile; then
        exec uwsm start hyprland.desktop
    fi
fi
EOF
  chown "${REAL_USER}:${REAL_USER}" "${zprofile_target}"
fi

sudo systemctl enable getty@tty1.service >/dev/null 2>&1
printf "%b\n" "${CGR}✓ Autologin Flicker-Free con UWSM listo.${CNC}"