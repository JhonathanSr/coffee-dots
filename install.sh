#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: Coffee-Dots Installer Main
# DESCRIPCIÓN: Script principal de orquestación para la instalación de dotfiles,
#              configuración del sistema y despliegue de herramientas en Arch.
# DEPENDENCIAS: bash, coreutils, paru/yay (AUR), sudo, mlocate (updatedb).
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 28/05/2026
# ==============================================================================

# Colores para mensajes
CRE=$(tput setaf 1) # Red
CYE=$(tput setaf 3) # Yellow
CGR=$(tput setaf 2) # Green
CBL=$(tput setaf 4) # Blue
BLD=$(tput bold)    # Bold
CNC=$(tput sgr0)    # Reset colors

# --- Configuración de Entorno ---
# Finaliza la ejecución si cualquier comando falla (Error Handling estricto).
set -e

# Rutas globales del repositorio
PATH_INSTALL="$HOME/Projects/coffee-dots/install"

# --- Manejo de Errores (Global Catch) ---
catch_errors() {
  echo -e "\n${CRE}${BLD}¡La instalación general de Coffee-Dots falló!${CNC}"
  echo "Puedes reintentarlo ejecutando: bash $HOME/coffee-dots/install.sh"
  echo "Si el error persiste, por favor repórtalo en: https://github.com/JhonathanSr/coffee-dots/issues"
}

# Trap para capturar la señal ERR y ejecutar la función de aviso global.
trap catch_errors ERR

# --- Funciones de Interfaz Visual ---
show_subtext() {
  echo -e "${CYE}${BLD}$1${CNC}"
  echo
}
# --- Fase 2: Instalación de Paquetes y Herramientas [2/5] ---
show_subtext "Instalando paquetes oficiales y del AUR [2/5]"
bash "$PATH_INSTALL/pacman.sh"
#bash "$PATH_INSTALL/paru.sh"
bash "$PATH_INSTALL/configs.sh"
bash "$PATH_INSTALL/git.sh"
bash "$PATH_INSTALL/firewall.sh"

# Sincronización final de la indexación de archivos locales
sudo updatedb

# --- Finalización ---
echo -e "\n${CGR}${BLD}¡Disfruta tu café con Arch Linux y Coffee-Dots! ☕${CNC}\n"

# Pausa de cortesía antes del reinicio necesario para aplicar cambios.
sleep 2
