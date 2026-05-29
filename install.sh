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
export COFFEE_PATH="$HOME/coffee-dots"
PATH_INSTALL="$COFFEE_PATH/.install"

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

# --- Fase 0: Pre-flight Checks ---
# Verificación de estado del sistema antes de iniciar.
source "$PATH_INSTALL/guard.sh"

# --- Fase 1: Inicialización del Sistema y Repositorios [1/5] ---
show_subtext "Inicializando repositorios y actualizando llaves... [1/5]"
bash "$PATH_INSTALL/00-system_init.sh"  # Tu antiguo aur.sh optimizado


# --- Fase 2: Instalación de Paquetes y Herramientas [2/5] ---
show_subtext "Instalando paquetes oficiales y del AUR [2/5]"
bash "$PATH_INSTALL/01-pacman.sh"
bash "$PATH_INSTALL/02-paru.sh"

# --- Fase 3: Despliegue de Configuraciones Estáticas y Aplicaciones [3/5] ---
show_subtext "Desplegando archivos de configuración (Dotfiles) y mimetypes [3/5]"

# Módulo que clona o copia tus carpetas espejo hacia ~/.config
bash "$PATH_INSTALL/03-configs.sh"

# --- Fase 4: Controladores de Hardware Inteligentes [4/5] ---
show_subtext "Analizando hardware e inyectando optimizaciones gráficas [4/5]"

# Módulo dedicado a revisar si tienes la GPU dedicada de la Lenovo LOQ o AMD
#bash "$PATH_INSTALL/04-.sh"

# --- Fase 5: Ajustes de Entorno, Hooks y Sistema [5/5] ---
show_subtext "Aplicando ganchos finales del sistema y activando servicios [5/5]"
# --- Fase 5: System Hooks [5/5] ---
printf "%b\n" "${CBL}${BLD}[Coffee-Dots] Ejecutando ganchos de sistema modulares...${CNC}"
if [ -d ".install/hooks" ]; then
  for hook in .install/hooks/[0-9]*.sh; do
    if [ -x "$hook" ]; then
      printf "%b\n" "${BLD}${CYE}→ Corriendo gancho: $(basename "$hook")${CNC}"
      "$hook"
    fi
  done
fi

# Sincronización final de la indexación de archivos locales
sudo updatedb

# --- Finalización ---
echo -e "\n${CGR}${BLD}¡Disfruta tu café con Arch Linux y Coffee-Dots! ☕${CNC}\n"

# Pausa de cortesía antes del reinicio necesario para aplicar cambios.
sleep 2
reboot
