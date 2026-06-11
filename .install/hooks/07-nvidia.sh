#!/usr/bin/env bash
# Componente: Optimización y Hardening de Kernel para GPUs NVIDIA (Wayland/Hyprland)

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"

# Asegurar que el directorio de logs exista antes de capturar errores
mkdir -p "$(dirname "$ERROR_LOG")"

trap 'printf "%s%sERROR:%s Fallo en configuración de Nvidia (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# ------------------------------------------------------------------------------
# 1. Detección de Hardware
# ------------------------------------------------------------------------------
if ! lspci | grep -qi 'VGA.*nvidia\|3D.*nvidia'; then
  exit 0
fi

printf "%b\n" "${BLD}${CYE}🚀 GPU Nvidia detectada. Aplicando parches y gestión de energía...${CNC}"

# ------------------------------------------------------------------------------
# 2. Persistencia de Memoria VRAM y Ahorro Dinámico (Fix DPMS & Batería)
# ------------------------------------------------------------------------------
nvidia_pm_conf="/etc/modprobe.d/nvidia-power-management.conf"
printf "%b\n" "${CYE}Configurando persistencia de VRAM y estados de energía dinámicos (D3)...${CNC}"

# Estructurar la configuración con gestión fina de energía para laptops híbridas
cat <<EOF | sudo tee "$nvidia_pm_conf" >/dev/null
# Forzar preservación de asignación de memoria al suspender (Evita pantallas negras)
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp

# Gestión dinámica de energía (Runtime PM): Apaga la GPU a 0W si no está en uso
options nvidia __nv_PRIME_profile_default_runtime_pm_management=1

# Habilitar modoset y framebuffer para liberar la consola de Linux al dormir la GPU
options nvidia_drm modeset=1 fbdev=1
EOF

printf "%b\n" "${CGR}✓ Configuración de energía avanzada inyectada en $nvidia_pm_conf.${CNC}"

# ------------------------------------------------------------------------------
# 3. Modoset Temprano (Initramfs)
# ------------------------------------------------------------------------------
should_regenerate_initramfs=false

if [ -f /etc/mkinitcpio.conf ]; then
  if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
    sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
    should_regenerate_initramfs=true
  fi
fi

# Forzar regeneración si creamos el archivo de power management por primera vez
if [ "$should_regenerate_initramfs" = true ] || [ ! -f "$nvidia_pm_conf" ]; then
  printf "%b\n" "${CYE}Detectando gestor de initramfs para aplicar cambios al kernel...${CNC}"
  if command -v cachyos-mkinitcpio &>/dev/null; then
    sudo cachyos-mkinitcpio -P >/dev/null 2>>"$ERROR_LOG"
  elif command -v mkinitcpio &>/dev/null; then
    sudo mkinitcpio -P >/dev/null 2>>"$ERROR_LOG"
  fi
fi

# ------------------------------------------------------------------------------
# 4. Parámetro de Kernel (cmdline para systemd-boot/grub legacy)
# ------------------------------------------------------------------------------
if [ -d /etc/cmdline.d ]; then
  echo "nvidia-drm.modeset=1" | sudo tee /etc/cmdline.d/nvidia.conf >/dev/null
fi

# ------------------------------------------------------------------------------
# 5. Servicios Systemd (Ciclo de Vida de Energía)
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
# 6. Variables de Entorno (Corrección de rutas y permisos)
# ------------------------------------------------------------------------------
# Obtener el usuario real si el script corre bajo sudo para evitar romper el $HOME
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

env_dir="$REAL_HOME/.config/environment.d"
env_target="$env_dir/10-nvidia.conf"

sudo -u "$REAL_USER" mkdir -p "$env_dir"
cat <<EOF | sudo -u "$REAL_USER" tee "$env_target" >/dev/null
LIBVA_DRIVER_NAME=nvidia
XDG_SESSION_TYPE=wayland
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia

# Optimización de energía para renderizado híbrido nativo de NVIDIA
__GL_GSYNC_ALLOWED=1
__GL_VRR_ALLOWED=1
EOF

# Asegurar permisos correctos al árbol alterado en la sesión de usuario
chown -R "$REAL_USER:$REAL_USER" "$env_dir"

printf "%b\n" "${CGR}✓ Suite de compatibilidad y ahorro de energía Nvidia configurada con éxito.${CNC}"
