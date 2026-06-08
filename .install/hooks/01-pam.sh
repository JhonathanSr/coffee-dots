#!/usr/bin/env bash
# Componente: Hardening de Autenticación (PAM)

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
BLD=$(tput bold)
CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
trap 'printf "%s%sERROR:%s Fallo en PAM hardening (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

if [ -f "/etc/pam.d/system-auth" ]; then
  printf "%b\n" "${BLD}${CYE}Endureciendo políticas de autenticación PAM (Faillock)...${CNC}"
  sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=60|' "/etc/pam.d/system-auth"
  sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=60|' "/etc/pam.d/system-auth"
  printf "%b\n" "${CGR}✓ Políticas PAM aplicadas.${CNC}"
fi

# generando keyring vacio
printf "%b\n" "${BLD}${CYE}Generando Keyring ..${CNC}"
if [ ! -f "$HOME/.local/share/keyrings/login.keyring" ]; then
  mkdir -p "$HOME/.local/share/keyrings"

  echo "" | gnome-keyring-daemon --unlock --components=secrets &>/dev/null
  echo "login" >"$HOME/.local/share/keyrings/default"
fi

printf "%b\n" "${CGR}✓ Politicas de autenticación endurecidas.${CNC}"
