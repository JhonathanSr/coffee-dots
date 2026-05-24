#!/bin/bash

# ==============================================================================
# SCRIPT: Timezone & Clock Synchronization
# DESCRIPCIÓN: Configura la zona horaria dinámica mediante tzupdate y establece
#              permisos de sudo sin contraseña para la sincronización horaria.
# DEPENDENCIAS: tzupdate, timedatectl, paru/yay.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Pre-flight Check & Instalación ---
# Verificamos si tzupdate (basado en geolocalización IP) está instalado.
if ! command -v tzupdate &>/dev/null; then
  echo "Instalando herramientas de sincronización horaria..."
  paru -S --noconfirm --needed tzupdate

  # --- Elevación de Privilegios (Sudoers) ---
  # Creamos una regla en sudoers.d para permitir que el script de actualización
  # horaria se ejecute sin solicitar contraseña, facilitando la automatización.
  # Esto permite ejecutar: sudo tzupdate y sudo timedatectl.
  sudo tee /etc/sudoers.d/timezoneupdate >/dev/null <<EOF
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF

  # Establecemos permisos restrictivos (Solo lectura para root) por seguridad.
  sudo chmod 0440 /etc/sudoers.d/timezoneupdate
fi

# --- Ejecución Inicial ---
# Se recomienda ejecutar la sincronización después de la configuración.
sudo tzupdate