#!/usr/bin/env bash
# Componente: Optimización y Hardening de Kernel para GPUs NVIDIA (Wayland/Hyprland)

CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); CBL=$(tput setaf 4); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
trap 'printf "%s%sERROR:%s Fallo en configuración de Nvidia (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# ------------------------------------------------------------------------------
# 1. Detección de Hardware Física
# ------------------------------------------------------------------------------
if ! lspci | grep -qi 'VGA.*nvidia\|3D.*nvidia'; then
  # Si no hay tarjeta Nvidia (como en tu setup principal AMD), el script termina en paz
  exit 0
fi

printf "%b\n" "${BLD}${CYE}🚀 GPU Nvidia detectada. Aplicando parches críticos para Wayland...${CNC}"

# ------------------------------------------------------------------------------
# 2. Modoset en mkinitcpio (Kernel Mode Setting - KMS Prematuro)
# ------------------------------------------------------------------------------
# Requisito indispensable para que Wayland inicie antes que el servidor gráfico nativo
if [ -f /etc/mkinitcpio.conf ]; then
  printf "%b\n" "${BLD}${CYE}Inyectando módulos DRM de Nvidia en mkinitcpio.conf...${CNC}"
  
  # Añade de forma segura los módulos obligatorios si no están presentes
  if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
    sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
    
    printf "%b\n" "${BLD}${CYE}Regenerando initramfs (mkinitcpio)...${CNC}"
    sudo mkinitcpio -P >/dev/null 2>>"$ERROR_LOG"
  fi
fi

# ------------------------------------------------------------------------------
# 3. Parámetro de Kernel: nvidia-drm.modeset=1
# ------------------------------------------------------------------------------
# Obliga al driver propietario a activar el soporte de renderizado directo
if [ -d /etc/cmdline.d ]; then
  printf "%b\n" "${BLD}${CYE}Configurando parámetro nvidia-drm.modeset=1...${CNC}"
  printf "nvidia-drm.modeset=1" | sudo tee /etc/cmdline.d/nvidia.conf >/dev/null
fi

# ------------------------------------------------------------------------------
# 4. Servicios Systemd para Suspensión/Sleeptime sin Glitches
# ------------------------------------------------------------------------------
# Evita que al suspender la laptop/PC, las texturas de Hyprland regresen corruptas
printf "%b\n" "${BLD}${CYE}Activando servicios de preservación de VRAM (Nvidia Systemd)...${CNC}"
local nvidia_services=(
  "nvidia-suspend.service"
  "nvidia-hibernate.service"
  "nvidia-resume.service"
)

for service in "${nvidia_services[@]}"; do
  sudo systemctl enable "$service" >/dev/null 2>>"$ERROR_LOG" || true
done

# ------------------------------------------------------------------------------
# 5. Variables de Entorno Globales para el Usuario
# ------------------------------------------------------------------------------
# Configuraciones requeridas para forzar el backend de hardware correcto
local env_target="$HOME/.config/environment.d/10-nvidia.conf"
if [ ! -f "$env_target" ]; then
  mkdir -p "$(dirname "$env_target")"
  cat <<EOF >"$env_target"
# Variables inyectadas por coffee-dots para Nvidia
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF
  chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$HOME/.config/environment.d"
fi

printf "%b\n" "${CGR}✓ Suite de compatibilidad Nvidia configurada con éxito.${CNC}"