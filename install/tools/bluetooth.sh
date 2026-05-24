#!/bin/bash

# ==============================================================================
# SCRIPT: Bluetooth Management Setup
# DESCRIPCIÓN: Instalación y configuración del stack de Bluetooth. Implementa
#              bluetui para una gestión eficiente desde la terminal y asegura
#              que el hardware no esté bloqueado por software.
# DEPENDENCIAS: bluetui, bluez, bluez-utils, rfkill, systemd.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Instalación de Herramientas ---
# 'bluetui' proporciona una interfaz TUI minimalista ideal para Tiling Window Managers.
sudo pacman -S --noconfirm --needed bluetui

# --- Configuración y Activación del Servicio ---
# Habilitamos el demonio de Bluetooth (bluez) para que inicie con el sistema.
# --now: Inicia el servicio inmediatamente sin requerir reinicio.
sudo systemctl enable --now bluetooth.service

# --- Desbloqueo de Hardware ---
# Utilizamos rfkill para asegurar que el adaptador Bluetooth no tenga un
# 'soft block', permitiendo que el radio emita señal correctamente.
sudo rfkill unblock bluetooth
