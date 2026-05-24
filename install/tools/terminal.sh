#!/bin/bash

# ==============================================================================
# SCRIPT: Terminal Tools & Dev Utilities
# DESCRIPCIÓN: Instalación de herramientas de terminal y utilidades de desarrollo
#              esenciales para una experiencia de usuario completa y eficiente 
#              en el entorno de desarrollo.
# DEPENDENCIAS: paru, coreutils, network-utils.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Utilidades de Red y Descarga ---
# Herramientas fundamentales para la transferencia de datos y diagnóstico de red.
paru -S --noconfirm --needed wget curl inetutils whois

# --- Navegación de Archivos y Búsqueda Moderna ---
# Reemplazos modernos de comandos tradicionales (ls, find, cd, grep) optimizados 
# para velocidad y legibilidad (Rust-based tools).
paru -S --noconfirm --needed fd eza fzf ripgrep zoxide

# --- Manipulación y Visualización de Datos ---
# Herramientas para el manejo de streams de texto, JSON, XML y gestión 
# del portapapeles en entornos Wayland.
paru -S --noconfirm --needed bat jq xmlstarlet wl-clipboard

# --- Monitorización y Rendimiento ---
# Visualización estética de información del sistema y monitoreo de recursos (TUI).
paru -S --noconfirm --needed fastfetch btop nvtop

# --- Herramientas de Ayuda y Documentación ---
# Gestión de manuales, autocompletado de shell y búsqueda rápida de archivos indexados.
paru -S --noconfirm --needed man tldr less plocate bash-completion

# --- Gestión de Archivos ---
# Utilidades para la descompresión y manejo de paquetes de datos.
paru -S --noconfirm --needed unzip

# --- Terminales y Multiplexores ---
# Ghostty como emulador de terminal de alto rendimiento y Zellij para 
# la gestión de paneles y sesiones de terminal.
paru -S --noconfirm --needed ghostty zellij
