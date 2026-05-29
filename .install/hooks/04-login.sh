#!/bin/bash
# Componente: Autologin Seamless con VT Manager en C + UWSM (Flicker-Free & Cifrado)

CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); CBL=$(tput setaf 4); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"

# Captura exacta del usuario real (no-root) para no corromper la sesión gráfica
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

trap 'printf "%s%sERROR:%s Fallo en setup de Autologin UWSM (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

if ! command -v uwsm &>/dev/null; then
  printf "%b\n" "${CRE}⚠️ UWSM no está instalado. Saltando configuración de autologin.${CNC}"
  exit 0
fi

# ------------------------------------------------------------------------------
# 1. Compilación Segura del VT Manager (Seamless-Login)
# ------------------------------------------------------------------------------
if [ ! -x /usr/local/bin/seamless-login ]; then
  printf "%b\n" "${BLD}${CYE}Compilando binario de transición de bajo nivel (KD_GRAPHICS)...${CNC}"
  
  local src_tmp
  src_tmp=$(mktemp /tmp/seamless-login.XXXXXX.c)
  
  cat <<'CCODE' >"$src_tmp"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/kd.h>
#include <linux/vt.h>
#include <sys/wait.h>
#include <string.h>

int main(int argc, char *argv[]) {
    int vt_fd;
    int vt_num = 1; // Forzamos TTY1
    char vt_path[32];
    
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <session_command>\n", argv[0]);
        return 1;
    }
    
    snprintf(vt_path, sizeof(vt_path), "/dev/tty%d", vt_num);
    vt_fd = open(vt_path, O_RDWR);
    if (vt_fd < 0) {
        perror("Error al abrir VT");
        return 1;
    }
    
    // Forzar foco y activar modo gráfico para congelar la pantalla pre-boot
    ioctl(vt_fd, VT_ACTIVATE, vt_num);
    ioctl(vt_fd, VT_WAITACTIVE, vt_num);
    
    if (ioctl(vt_fd, KDSETMODE, KD_GRAPHICS) < 0) {
        perror("Error en KDSETMODE");
        close(vt_fd);
        return 1;
    }
    
    const char *clear_seq = "\33[H\33[2J";
    write(vt_fd, clear_seq, strlen(clear_seq));
    close(vt_fd);
    
    const char *home = getenv("HOME");
    if (home) chdir(home);
    
    execvp(argv[1], &argv[1]);
    return 1;
}
CCODE

  gcc -O2 -o /tmp/seamless-login "$src_tmp"
  sudo mv /tmp/seamless-login /usr/local/bin/seamless-login
  sudo chmod 755 /usr/local/bin/seamless-login
  rm -f "$src_tmp"
fi

# ------------------------------------------------------------------------------
# 2. Creación del Servicio Systemd uwsmLogin Dedicado
# ------------------------------------------------------------------------------
printf "%b\n" "${BLD}${CYE}Inyectando uwsmLogin.service amarrado a ${REAL_USER}...${CNC}"

sudo tee /etc/systemd/system/uwsmLogin.service >/dev/null <<EOF
[Unit]
Description=UWSM Seamless Auto-Login (Coffee-Dots)
After=systemd-user-sessions.service plymouth-quit-wait.service systemd-logind.service
Conflicts=getty@tty1.service
PartOf=graphical.target

[Service]
Type=simple
# El binario en C prepara la TTY y luego ejecuta UWSM de forma segura
ExecStart=/usr/local/bin/seamless-login uwsm start -o hyprland.desktop
User=${REAL_USER}
WorkingDirectory=${REAL_HOME}
Environment=HOME=${REAL_HOME} USER=${REAL_USER} XDG_SESSION_TYPE=wayland
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
StandardInput=tty
StandardOutput=journal
StandardError=journal+console
PAMName=login

[Install]
WantedBy=graphical.target
EOF

# ------------------------------------------------------------------------------
# 3. Conmutación y Limpieza de Servicios
# ------------------------------------------------------------------------------
printf "%b\n" "${BLD}${CYE}Sincronizando servicios con el gestor de arranque...${CNC}"

# Limpiamos remanentes en el .zprofile si quedaron de pruebas previas
local zprofile_target="${REAL_HOME}/.zprofile"
if [ -f "$zprofile_target" ]; then
  sed -i '/# \[Coffee-Dots\] Arranque automático/,/fi/d' "$zprofile_target"
fi

sudo systemctl daemon-reload

# Apagamos getty en tty1 para cederle el control total a tu binario en C
sudo systemctl disable getty@tty1.service >/dev/null 2>&1 || true

# Activamos el servicio Seamless definitivo
sudo systemctl enable uwsmLogin.service >/dev/null 2>>"$ERROR_LOG"

printf "%b\n" "${CGR}✓ Transición VT en C y servicio uwsmLogin configurados con éxito.${CNC}"
