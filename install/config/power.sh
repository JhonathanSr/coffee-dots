#!/bin/bash

# ==============================================================================
# SCRIPT: Power Management & Profiles
# DESCRIPCIÓN: Configura la gestión de energía utilizando power-profiles-daemon.
#              Detecta automáticamente si el sistema es una laptop o desktop
#              para aplicar el perfil de rendimiento o balanceado.
# DEPENDENCIAS: power-profiles-daemon, coreutils, systemd.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Instalación de Dependencias ---
# Instalamos el demonio oficial de perfiles de energía (compatible con GNOME/KDE/Hyprland).
if ! command -v powerprofilesctl &>/dev/null; then
  paru -S --noconfirm power-profiles-daemon
fi

# Aseguramos que el servicio esté activo antes de intentar cambiar perfiles.
sudo systemctl enable --now power-profiles-daemon.service

# --- Lógica de Detección de Hardware ---

# Comprobamos la existencia de dispositivos de batería en el sistema de archivos virtual /sys.
if ls /sys/class/power_supply/BAT* &>/dev/null; then
  
  # --- Configuración para Laptops ---
  # Establecemos un perfil 'balanced' para optimizar la autonomía sin sacrificar fluidez.
  powerprofilesctl set balanced || true

  # Habilitamos el timer del monitor de batería del usuario.
  # Este servicio gestiona notificaciones de descarga y estados críticos.
  systemctl --user enable --now battery-monitor.timer || true
  
else
  
  # --- Configuración para Desktop (Workstation) ---
  # Al no contar con batería, forzamos el perfil 'performance'.
  # Ideal para tareas de desarrollo (Spring Boot/Angular) y gaming en Linux.
  powerprofilesctl set performance || true
  
fi