#!/bin/bash

# ==============================================================================
# SCRIPT: Shell, Archiving & Input Customization
# DESCRIPCIÓN: Instalación de Zsh, configuración de utilidades de compresión,
#              personalización de temas visuales y remapeo de teclado (Caps Lock
#              a F13) para optimizar la productividad en Hyprland.
# DEPENDENCIAS: paru, zsh, git, gsettings, xremap-hypr-bin.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Entorno de Shell y Navegación ---
# Instalamos Yazi (gestor de archivos TUI) y Zsh como intérprete principal.
paru -S --noconfirm --needed yazi zsh
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --keep

# --- Utilidades de Compresión y Archivo ---
# Soporte para múltiples formatos de datos esenciales para el manejo de paquetes.
paru -S --noconfirm --needed zip 7zip tar gzip xz zstd bzip3 cpio arj

# Instalación de fzf-tab para mejorar el autocompletado en Zsh mediante fzf.
sudo git clone https://GitHub.com/Aloxaf/fzf-tab /usr/share/zsh/plugins/fzf-tab-git

# Despliegue de la configuración personalizada de Zsh.
cp "$HOME/coffee-dots/default/zsh/.zshrc" ~/.zshrc

# --- Gestión del Intérprete de Comandos (Default Shell) ---
change_default_shell() {
  zsh_path=$(command -v zsh)
  sleep 3

  if [ -z "$zsh_path" ]; then
    printf "%b\n\n" "Zsh no está instalado, no es posible cambiar la shell"
    return 1
  fi

  if [ "$SHELL" != "$zsh_path" ]; then
    printf "%b\n" "Cambiando shell a zsh..."
    if chsh -s "$zsh_path"; then
      printf "%b\n" "\nShell cambiada exitosamente!"
    else
      printf "%b\n\n" "\nError cambiando shell!"
    fi
  else
    printf "%b\n\n" "Zsh ya es tu shell predefinida!"
  fi
  sleep 3
}

change_default_shell

# --- Estética y Temas GTK/QT ---
# Instalamos y aplicamos el tema Yaru para una apariencia consistente.
paru -S --noconfirm --needed yaru-icon-theme yaru-gtk-theme chafa

gsettings set org.gnome.desktop.interface gtk-theme "Yaru-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru"

# Limpieza de paquetes innecesarios para la gestión de red.
if ! command -v iwctl &>/dev/null; then
  paru -R --noconfirm iwd
fi

# Configuración del motor Kvantum para aplicaciones QT.
paru -S --noconfirm --needed kvantum-theme-materia
kvantummanager --set MateriaDark

# --- Remapeo de Teclado (xremap) ---
# Transforma Caps Lock en F13 para binds personalizados en fcitx5.
paru -S --noconfirm --needed xremap-hypr-bin
cp -r "$HOME/coffee-dots/default/xremap" ~/.config

# Integración con el autoinicio de Hyprland.
if ! grep -q "exec-once = xremap ~/.config/xremap/config.yml" ~/.config/hypr/autostart.conf; then
  echo "exec-once = xremap ~/.config/xremap/config.yml" >> ~/.config/hypr/autostart.conf
fi

# --- Ajustes Finales de Sistema ---
# Visibilidad de snapshots ZFS si se detecta el sistema de archivos.
if command -v zfs >/dev/null 2>&1; then
  sudo zfs set snapdir=visible zpcachyos
fi

# Otorgar permisos de ejecución a los binarios locales de Coffee-Dots.
chmod +x "$HOME/.config/coffee/bin/"*

# --- Entornos de Desarrollo (Opcional/Comentado) ---
# Gestión de versiones para Java/Kotlin (SDKMAN) y Node.js (NVM).
# curl -s "https://get.sdkman.io" | bash
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
