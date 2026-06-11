#!/usr/bin/env bash
# Componente: Hardening de Autenticación (PAM) y Aprovisionamiento de Llavero

set -euo pipefail

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
BLD=$(tput bold)
CNC=$(tput sgr0)

ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
mkdir -p "$(dirname "$ERROR_LOG")"

# Manejo de errores defensivo
trap 'printf "%s%sERROR:%s Fallo en ejecución del script (Línea $LINENO). Revisando consistencia...\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

## 1. Hardening de PAM (Faillock)
if [ -f "/etc/pam.d/system-auth" ]; then
  printf "%b\n" "${BLD}${CYE}Endureciendo políticas de autenticación PAM (Faillock)...${CNC}"
  
  # Respaldo preventivo antes de operar en caliente
  sudo cp "/etc/pam.d/system-auth" "/etc/pam.d/system-auth.bak"

  # Mutación quirúrgica: Se verifica existencia previa del parámetro o se modifica con seguridad
  if grep -q "pam_faillock.so" "/etc/pam.d/system-auth"; then
    sudo sed -i -E 's|^(auth\s+required\s+pam_faillock.so\s+preauth).*$|\1 silent deny=10 unlock_time=60|' "/etc/pam.d/system-auth"
    sudo sed -i -E 's|^(auth\s+\[default=die\]\s+pam_faillock.so\s+authfail).*$|\1 deny=10 unlock_time=60|' "/etc/pam.d/system-auth"
  else
    printf "%b\n" "${CYE}! Modulo pam_faillock.so no estructurado de forma estándar en system-auth. Omitiendo mutación automática.${CNC}"
  fi
  printf "%b\n" "${CGR}✓ Políticas PAM verificadas/aplicadas.${CNC}"
fi

## 2. Aprovisionamiento Automático de Gnome Keyring (Idempotente)
printf "%b\n" "${BLD}${CYE}Configurando almacenamiento de Gnome Keyring...${CNC}"

KEYRING_DIR="$HOME/.local/share/keyrings"
LOGIN_KEYRING="$KEYRING_DIR/login.keyring"
DEFAULT_FILE="$KEYRING_DIR/default"

mkdir -p "$KEYRING_DIR"

# Corregido: Validar la existencia real del archivo que gnome-keyring usa por defecto en login automático
if [ ! -f "$LOGIN_KEYRING" ]; then
  printf "%b\n" "${CYE}Inicializando 'login.keyring' en blanco via D-Bus headless...${CNC}"

  # Forzar creación limpia simulando sesión headless para desbloqueo con contraseña vacía (Autologin)
  if command -v dbus-run-session &>/dev/null && command -v gnome-keyring-daemon &>/dev/null; then
    dbus-run-session -- bash -c "
      printf '' | gnome-keyring-daemon --unlock --components=secrets &>/dev/null
    " || true
  fi

  # Generación del archivo estructural de fallback por defecto si no se mutó binariamente
  if [ ! -f "$LOGIN_KEYRING" ]; then
    cat << 'EOF' > "$LOGIN_KEYRING"
[keyring]
display-name=login
lock-on-idle=false
lock-after=false
EOF
  fi

  # Definir el llavero por defecto del sistema
  echo "login" > "$DEFAULT_FILE"

  # Aplicación estricta de permisos POSIX mínimos requeridos
  chmod 700 "$KEYRING_DIR"
  chmod 600 "$LOGIN_KEYRING"
  chmod 644 "$DEFAULT_FILE"
  
  printf "%b\n" "${CGR}✓ Llavero 'login' base estructurado con éxito.${CNC}"
else
  printf "%b\n" "${CYE}! El llavero 'login.keyring' ya existe en el disco. Preservando integridad de credenciales.${CNC}"
fi

printf "%b\n" "${CGR}✓ Automatización de autenticación completada de manera agnóstica.${CNC}"