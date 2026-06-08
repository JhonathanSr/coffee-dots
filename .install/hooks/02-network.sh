#!/usr/bin/env bash
# Componente: Optimización de Red, DNS y Tiempos de Arranque

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
	sudo systemctl disable "$service" >>"$ERROR_LOG" || true
        sudo systemctl mask "$service" >>"$ERROR_LOG" || true
  fi
done
printf "%b\n" "${CGR}✓ Optimización de red y boot completada.${CNC}"
