#!/bin/bash

# ==============================================================================
# SCRIPT: Network Wait-Online Optimizer
# DESCRIPCIÓN: Deshabilita y enmascara el servicio de espera de red de systemd.
#              Previene retrasos (timeouts) de hasta 90 segundos durante el 
#              arranque o la instalación en redes lentas o inestables.
# DEPENDENCIAS: systemd.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Optimización de systemd ---

# 1. Disable: Evita que el servicio se cargue automáticamente en el siguiente arranque.
sudo systemctl disable systemd-networkd-wait-online.service

# 2. Mask: Crea un enlace simbólico a /dev/null para que el servicio no pueda 
#    ser iniciado manualmente ni por otro servicio dependiente, garantizando 
#    que el proceso de instalación no se detenga.
sudo systemctl mask systemd-networkd-wait-online.service