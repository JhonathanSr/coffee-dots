#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: Core System & Official Packages Setup
# DESCRIPCIÓN: Instalación de la infraestructura base del sistema, compositor
#              Hyprland, utilidades oficiales, herramientas de compilación,
#              runtimes de desarrollo y paquetes multimedia estables.
# DEPENDENCIAS: pacman, sudo.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 29/05/2026
# ==============================================================================

# Colores para mensajes (Sincronizados con el ecosistema Coffee-Dots)
CRE=$(tput setaf 1) # Red
CYE=$(tput setaf 3) # Yellow
CGR=$(tput setaf 2) # Green
CBL=$(tput setaf 4) # Blue
BLD=$(tput bold)    # Bold
CNC=$(tput sgr0)    # Reset colors

ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"

# --- Manejo Quirúrgico de Errores ---
log_error() {
  local error_msg="$1"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  printf "[%s] ERROR (Fase 01-Pacman): %s\n" "${timestamp}" "${error_msg}" >>"$ERROR_LOG"
  printf "%s%sERROR:%s %s\n" "${CRE}" "${BLD}" "${CNC}" "${error_msg}" >&2
}

# Trap local para capturar fallos en la instalación masiva
catch_pacman_errors() {
  log_error "La instalación de componentes críticos (Pacman) falló en la línea $LINENO."
  printf "\n%s%sPuedes reintentar este bloque de forma aislada ejecutando:%s\n" "${CYE}" "${BLD}" "${CNC}"
  printf "  bash $HOME/coffee-dots/.install/01-pacman.sh\n\n"
}

trap catch_pacman_errors ERR

# ==============================================================================
# EJECUCIÓN DEL MÓDULO
# ==============================================================================

install_official_packages() {
  printf "%b\n" "${CBL}${BLD}[Coffee-Dots] Sincronizando sistema e instalando paquetes oficiales...${CNC}\n"

  # Actualización previa de las bases de datos del sistema
  sudo pacman -Syu --noconfirm

  # Lista consolidada de paquetes de repositorios oficiales
  local CORE_PACKAGES=(
    # --- Base Gráfica y Core Hyprland ---
    "hyprland"
    "hyprland-guiutils"
    "xdg-desktop-portal-hyprland"
    "xdg-desktop-portal-gtk"
    "qt6-wayland"
    "hyprlock"
    "hypridle"
    "hyprpicker"
    "hyprshot"
    "hyprsunset"
    "hyprpaper"
    "rofi"
    "hyprpolkitagent"
    
    # --- Base de Compilación (Build Essentials) ---
    "gcc"
    "cmake"
    "make"
    "ninja"
    "clang"
    "llvm"
    
    # --- Herramientas de Terminal y Shell ---
    "zsh"
    "github-cli"
    "lazygit"
    "wget"
    "curl"
    "inetutils"
    "whois"
    "fastfetch"
    "btop"
    "nvtop"
    "man"
    "tldr"
    "less"
    "plocate"
    "chafa"
    "jq"
    "xmlstarlet"
    "imagemagick"
    "neovim"
    "wiremix"

    # --- Sistema de Archivos, Compresión y ZFS ---
    "zip"
    "tar"
    "gzip"
    "xz"
    "zstd"
    "cpio"
    
    # --- Multimedia, Audio y Control de Hardware ---
    "mpv"
    "imv"
    "feh"
    "evince"
    "brightnessctl"
    "playerctl"
    "pamixer"
    "wireplumber"
    "pipewire-alsa"
    "pipewire-pulse"
    "libva-utils"
    "ffmpegthumbnailer"
    "nautilus"
    "nautilus-python"
    "sushi"
    
    # --- Entrada de Texto y Clipboard ---
    "fcitx5"
    "fcitx5-gtk"
    "fcitx5-configtool"
    "wl-clipboard"
    
    # --- Captura y Grabación de Pantalla ---
    "slurp"
    "grim"
    "wf-recorder"
    
    
    # --- Estética, Iconos y Fuentes Base ---
    "kvantum"
    "gnome-themes-extra"
    "yaru-icon-theme"
    "libnotify"
    "libqalculate"
    "fontconfig"
    "ttf-jetbrains-mono"
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "noto-fonts-extra"

    "waybar"
    "mako"
    "swayosd"
    "uwsm"
    "fd"
    "eza"
    "fzf"
    "bat"
    "ripgrep"
    "zoxide"
    "docker"
    "docker-buildx"
    "docker-compose"
  )

  sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"
}

activate_system_timers() {
  printf "\n%b\n" "${BLD}${CYE}Activando servicios y timers de indexación (CachyOS)...${CNC}"
  
  # Intentar activar primero el timer optimizado de CachyOS
  if sudo systemctl enable --now plocate-driven-updatedb.timer >/dev/null 2>>"$ERROR_LOG"; then
    printf "%b\n" "${CGR}✓ Timer plocate-driven-updatedb activado.${CNC}"
  # Fallback al timer estándar de Arch si la unidad anterior no responde
  elif sudo systemctl enable --now plocate-updatedb.timer >/dev/null 2>>"$ERROR_LOG"; then
    printf "%b\n" "${CGR}✓ Timer plocate-updatedb estándar activado.${CNC}"
  else
    log_error "No se pudo activar el timer de plocate (Unidad no encontrada en este estado del boot)."
  fi
}

# CONTROL PRINCIPAL
# ==============================================================================
main() {
  install_official_packages
  activate_system_timers

  printf "\n%b\n" "${CGR}✓ [Fase 2] Paquetes oficiales e infraestructura instalados correctamente.${CNC}"
}

main "$@"
