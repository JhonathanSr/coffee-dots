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
# ==============================================================================
# EJECUCIÓN DEL MÓDULO
# ==============================================================================

install_official_packages() {
  printf "%b\n" "${CBL}${BLD}[Coffee-Dots] Sincronizando sistema e instalando paquetes oficiales...${CNC}\n"

  # Actualización previa de las bases de datos del sistema
  sudo pacman -Syu --noconfirm

  # Lista consolidada de paquetes de repositorios oficiales
  local CORE_PACKAGES=(
    "ninja"
    "zsh"
    "github-cli"
    "lazygit"
    "fastfetch"
    "btop"
    "tldr"
    "chafa"
    "xmlstarlet"
    "neovim"
    "zip"
    "imv"
    "feh"
    "evince"
    "eza"
    "fzf"
    "bat"
    "ripgrep"
    "zoxide"
    "docker"
    "docker-buildx"
    "docker-compose"
    "sshfs"
    "ghostty"
    "zellij"
    "mise"
    "lazydocker"
    "zen-browser-bin"
    "localsend"
    "obsidian"
    "steam"
    "spotify-launcher"

  )

  sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"
}

# CONTROL PRINCIPAL
# ==============================================================================
main() {
  install_official_packages

  printf "\n%b\n" "${CGR}✓ [Fase 2] Paquetes oficiales e infraestructura instalados correctamente.${CNC}"
}

main "$@"
