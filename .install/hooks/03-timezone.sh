#!/usr/bin/env bash
# Componente: Sincronización Horaria Automática (Sudoers & tzupdate)

CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
trap 'printf "%s%sERROR:%s Fallo en configuración horaria (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

printf "%b\n" "${BLD}${CYE}Configurando reglas sudoers para sincronización horaria...${CNC}"
sudo tee /etc/sudoers.d/timezoneupdate >/dev/null <<EOF
# Regla generada por coffee-dots para sincronización horaria automática
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
sudo chmod 0440 /etc/sudoers.d/timezoneupdate

if command -v tzupdate &>/dev/null; then
  printf "%b\n" "${BLD}${CYE}Sincronizando reloj del sistema vía tzupdate...${CNC}"
  sudo tzupdate
  printf "%b\n" "${CGR}✓ Zona horaria sincronizada con éxito.${CNC}"
else
  printf "%b\n" "${CRE}⚠️ tzupdate no detectado en el sistema. Sincronización omitida.${CNC}"
fi