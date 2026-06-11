#!/usr/bin/env bash
# Componente: Hardening de Autenticación (PAM) y Aprovisionamiento de Llavero

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

# --- Generando Keyring vacío estructurado ---
printf "%b\n" "${BLD}${CYE}Generando Keyring sin fricciones para Autologin...${CNC}"

KEYRING_DIR="$HOME/.local/share/keyrings"

if [ ! -f "$KEYRING_DIR/login.keyring" ]; then
  mkdir -p "$KEYRING_DIR"

  # Creamos un entorno D-Bus temporal para que gnome-keyring pueda estructurar el archivo físico
  # Esto garantiza que se cree el 'login.keyring' con hash nulo sin importar el entorno actual
  dbus-run-session -- bash -c "
    echo '' | gnome-keyring-daemon --unlock --components=secrets &>/dev/null
  "

  # Forzamos los metadatos de control para que el sistema sepa que 'login' es el primario
  echo "login" > "$KEYRING_DIR/default"
  
  # Seguridad Unix estricta (Permisos 600 requeridos por libsecret)
  chmod 700 "$KEYRING_DIR"
  chmod 600 "$KEYRING_DIR"/*
  
  printf "%b\n" "${CGR}✓ Llavero 'login' (Master) creado con contraseña vacía.${CNC}"
else
  printf "%b\n" "${CYE}! El llavero ya existe en el disco. Omitiendo para preservar credenciales.${CNC}"
fi

printf "%b\n" "${CGR}✓ Politicas de autenticación endurecidas y aprovisionadas.${CNC}"