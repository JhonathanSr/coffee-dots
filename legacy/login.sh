#!/bin/bash
# ==============================================================================
# SCRIPT: UWSM Seamless Login Setup
# DESCRIPCIÓN: Implementa un inicio de sesión automático "flicker-free" mediante
#              un gestor de VT (Virtual Terminal) escrito en C y un servicio
#              systemd. Replica el comportamiento de SDDM para una transición 
#              limpia desde Plymouth/Boot hasta Hyprland.
# DEPENDENCIAS: gcc, uwsm, systemd, hyprland.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 14/05/2026
# ==============================================================================

# --- Pre-flight Check ---
# UWSM es vital para gestionar la sesión de Wayland correctamente con systemd.
if ! command -v uwsm &>/dev/null; then
  echo "Instalando UWSM para gestión de sesión..."
  paru -S --noconfirm uwsm
fi

# --- Compilación del Gestor de VT (Seamless-Login) ---
# Este componente se encarga de preparar la TTY1 en modo gráfico (KD_GRAPHICS)
# para evitar que el cursor o texto de la consola interrumpan el arranque.
if [ ! -x /usr/local/bin/seamless-login ]; then
  echo "Compilando binario de transición VT..."
  cat <<'CCODE' >/tmp/seamless-login.c
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
    
    // Activación y espera de la VT para asegurar foco
    ioctl(vt_fd, VT_ACTIVATE, vt_num);
    ioctl(vt_fd, VT_WAITACTIVE, vt_num);
    
    // Establecer modo gráfico para ocultar artefactos de la terminal
    if (ioctl(vt_fd, KDSETMODE, KD_GRAPHICS) < 0) {
        perror("Error en KDSETMODE");
        close(vt_fd);
        return 1;
    }
    
    // Limpieza de pantalla antes de ceder el control
    const char *clear_seq = "\33[H\33[2J";
    write(vt_fd, clear_seq, strlen(clear_seq));
    close(vt_fd);
    
    // Cambio al directorio personal y ejecución de la sesión (UWSM)
    const char *home = getenv("HOME");
    if (home) chdir(home);
    
    execvp(argv[1], &argv[1]);
    return 1;
}
CCODE

  gcc -o /tmp/seamless-login /tmp/seamless-login.c
  sudo mv /tmp/seamless-login /usr/local/bin/seamless-login
  sudo chmod +x /usr/local/bin/seamless-login
  rm /tmp/seamless-login.c
fi

# --- Configuración del Servicio Systemd ---
# Creamos un servicio de sistema que reemplace al getty estándar en tty1.
if [ ! -f /etc/systemd/system/uwsmLogin.service ]; then
  echo "Creando servicio uwsmLogin.service..."
  cat <<EOF | sudo tee /etc/systemd/system/uwsmLogin.service
[Unit]
Description=UWSM Seamless Auto-Login
Documentation=https://github.com/basecamp/omarchy
Conflicts=getty@tty1.service
After=systemd-user-sessions.service getty@tty1.service systemd-logind.service
PartOf=graphical.target

[Service]
Type=simple
# Ejecutamos el wrapper de C que lanza UWSM con el desktop de Hyprland
ExecStart=/usr/local/bin/seamless-login uwsm start -- hyprland.desktop
Restart=always
RestartSec=2
User=$USER
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
fi

# --- Gestión de Servicios ---

# Habilitamos el nuevo servicio de inicio de sesión fluido.
if ! systemctl is-enabled uwsmLogin.service &>/dev/null; then
  sudo systemctl enable uwsmLogin.service
fi

# Deshabilitamos el getty tradicional de tty1 para evitar conflictos de recursos.
if systemctl is-enabled getty@tty1.service &>/dev/null; then
  sudo systemctl disable getty@tty1.service
fi