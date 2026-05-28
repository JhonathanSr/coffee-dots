#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: Coffee-Dots Installer Main
# DESCRIPCIÓN: Script principal de orquestación para la instalación de dotfiles,
#              configuración del sistema y despliegue de herramientas en Arch.
# DEPENDENCIAS: bash, coreutils, paru/yay (AUR), sudo, mlocate (updatedb).
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 14/05/2026
# ==============================================================================

# --- Configuración de Entorno ---
# Finaliza la ejecución si cualquier comando falla (Error Handling estricto).
set -e

# Exportamos el PATH para incluir el directorio del repositorio.
export PATH="$HOME/coffee-dots:$PATH"
PATH_INSTALL="$HOME/coffee-dots/install"

# --- Manejo de Errores (Global Catch) ---
# Se ejecuta cuando un comando retorna un código de salida distinto de cero.
catch_errors() {
  echo -e "\n\e[31m¡La instalación de Dots falló!\e[0m"
  echo "Puedes reintentarlo ejecutando: bash $HOME/coffee-dots/install.sh"
  echo "Si el error persiste, por favor repórtalo con: bash $HOME/coffee-dots/report-error.sh"
}

# Trap para capturar la señal ERR y ejecutar la función de limpieza/aviso.
trap catch_errors ERR

# --- Funciones de Interfaz Visual ---

# show_subtext: Imprime mensajes de estado y progreso en la instalación.
show_subtext() {
  echo "$1"
  echo
}

# --- Fase 0: Pre-flight Checks ---
# Verificación de privilegios, conexión y estado del sistema antes de iniciar.
source "$PATH_INSTALL/preflight/guard.sh"
source "$PATH_INSTALL/preflight/aur.sh"
source "$PATH_INSTALL/preflight/presentation.sh"
#source "$PATH_INSTALL/preflight/installed.sh"

# --- Fase 1: Configuración Base [1/5] ---

show_subtext "¡Listo para instalar! [1/5]"

source "$PATH_INSTALL/config/config.sh"
source "$PATH_INSTALL/config/network.sh"
source "$PATH_INSTALL/config/power.sh"
source "$PATH_INSTALL/config/timezones.sh"
source "$PATH_INSTALL/config/login.sh"

# --- Fase 2: Herramientas y Entorno [2/5] ---
show_subtext "Instalando herramientas y entorno [2/5]"

source "$PATH_INSTALL/tools/development.sh"   # Java, Spring Boot, Angular.
source "$PATH_INSTALL/tools/terminal.sh"      # Ghostty, Zsh, etc.
source "$PATH_INSTALL/tools/desktop.sh"       # Utilidades de escritorio.
source "$PATH_INSTALL/tools/hyprlandia.sh"    # Compositor y Rice.
source "$PATH_INSTALL/tools/theme.sh"         # Apariencia GTK/Icons.
source "$PATH_INSTALL/tools/bluetooth.sh"
source "$PATH_INSTALL/tools/fonts.sh"

# --- Fase 3: Aplicaciones y Tipos MIME [3/5] ---
show_subtext "Configurando aplicaciones y mimetypes [3/5]"

source "$PATH_INSTALL/apps/mimetypes.sh"

# --- Fase 4: Configuraciones Extra [4/5] ---
show_subtext "Aplicando configuraciones adicionales [4/5]"

source "$PATH_INSTALL/extra/extra.sh"

# --- Fase 5: Actualización Final del Sistema [5/5] ---
show_subtext "Sincronizando y actualizando sistema [5/5]"

# Actualizamos la base de datos de archivos y el sistema completo vía AUR helper.
sudo updatedb
paru -Syu --noconfirm

# --- Finalización ---
show_subtext "¡Disfruta tu café con Arch Linux y Coffee-Dots!"

# Pausa de cortesía antes del reinicio necesario para aplicar cambios.
sleep 2
reboot
