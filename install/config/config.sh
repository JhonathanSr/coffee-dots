#!/bin/bash

# ==============================================================================
# SCRIPT: System & Dotfiles Configuration
# DESCRIPCIÓN: Despliegue de archivos de configuración (ricing), endurecimiento
#              de seguridad PAM, optimización de red y aliases globales de Git.
# DEPENDENCIAS: coreutils (cp, mkdir, sed), sudo, git, systemd.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 14/05/2026
# ==============================================================================

# --- Despliegue de Dotfiles (Rice) ---
# Copiamos recursivamente todas las configuraciones del repositorio al HOME.
# Esto incluye Hyprland, Waybar, Neovim, Ghostty, etc.
#cp -R "$HOME/coffee-dots/config/"* ~/.config/

# --- Configuración de Shell y Terminal ---
# Sobrescribimos los archivos base de Bash para integrar el entorno Coffee.
cp "$HOME/coffee-dots/default/bash/bashrc" ~/.bashrc
cp "$HOME/coffee-dots/default/bash/inputrc" ~/.inputrc

# --- Estructura de Directorios ---
# Aseguramos la existencia del directorio para launchers de aplicaciones de usuario.
mkdir -p ~/.local/share/applications

# --- Seguridad: Hardening de Autenticación (PAM) ---
# Modificamos pam_faillock para mitigar ataques de fuerza bruta.
# deny=10: Bloquea la cuenta tras 10 intentos fallidos.
# unlock_time=60: El bloqueo dura 60 segundos antes de permitir reintentos.
sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=60|' "/etc/pam.d/system-auth"
sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=60|' "/etc/pam.d/system-auth"

# --- Optimización de Sistema y Red ---
# Establecemos los DNS de Cloudflare (1.1.1.1) mediante systemd-resolved.
sudo cp "$HOME/coffee-dots/default/systemd/resolved.conf" /etc/systemd/

# Nota: El ajuste de MTU Probing está comentado para evitar conflictos en redes locales específicas.
# echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf

# --- Configuración Global de Git ---
# Definición de atajos (aliases) para agilizar el flujo de trabajo de desarrollo.
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

# Configuraciones de comportamiento: Rebase por defecto y rama principal 'master'.
git config --global pull.rebase true
git config --global init.defaultBranch master

# --- Gestión de Notas Personales ---
# Inicialización del entorno de notas en Markdown.
mkdir -p ~/Documents/Notes
cp "$HOME/dots/default/notes.md" ~/Documents/Notes

