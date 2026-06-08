#!/usr/bin/env bash
# Componente: Optimización y Hardening de Kernel para GPUs NVIDIA (Wayland/Hyprland)

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
trap 'printf "%s%sERROR:%s Fallo en configuración de Nvidia (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# ------------------------------------------------------------------------------
# 1. Detección de Hardware
# ------------------------------------------------------------------------------
if ! lspci | grep -qi 'VGA.*nvidia\|3D.*nvidia'; then
  exit 0
fi

printf "%b\n" "${BLD}${CYE}🚀 GPU Nvidia detectada. Aplicando parches...${CNC}"

# ------------------------------------------------------------------------------
# 2. Modoset en mkinitcpio
# ------------------------------------------------------------------------------
if [ -f /etc/mkinitcpio.conf ]; then
  if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
    sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
    sudo mkinitcpio -P >/dev/null 2>>"$ERROR_LOG"
  fi
fi

# ------------------------------------------------------------------------------
# 3. Parámetro de Kernel
# ------------------------------------------------------------------------------
if [ -d /etc/cmdline.d ]; then
  echo "nvidia-drm.modeset=1" | sudo tee /etc/cmdline.d/nvidia.conf >/dev/null
fi

# ------------------------------------------------------------------------------
# 4. Servicios Systemd
# ------------------------------------------------------------------------------
nvidia_services=(
  "nvidia-suspend.service"
  "nvidia-hibernate.service"
  "nvidia-resume.service"
)

for service in "${nvidia_services[@]}"; do
  sudo systemctl enable "$service" >/dev/null 2>>"$ERROR_LOG" || true
done

# ------------------------------------------------------------------------------
# 5. Variables de Entorno (Corrección de rutas y permisos)
# ------------------------------------------------------------------------------
env_dir="$HOME/.config/environment.d"
env_target="$env_dir/10-nvidia.conf"

mkdir -p "$env_dir"
cat <<EOF >"$env_target"
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF

# Aplicar permisos al usuario actual (evitar problemas si se ejecutó con sudo)
sudo chown -R "$USER:$USER" "$env_dir"

printf "%b\n" "${CGR}✓ Suite de compatibilidad Nvidia configurada con éxito.${CNC}"

