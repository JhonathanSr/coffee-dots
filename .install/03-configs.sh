#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Name:        03-configs.sh
# Description: Dynamic dotfiles deployment, MIME types mapping, and ZDOTDIR PATH setup.
# Style:       coffee-dots ☕
# -----------------------------------------------------------------------------

# --- COFFEE BLEND (Colors & Variables) ---------------------------------------
CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

# Base paths for the ecosystem
REPO_CONFIG_DIR="${REAL_HOME}/coffee-dots/config"
TARGET_CONFIG_DIR="${REAL_HOME}/.config"
COFFEE_BIN_DIR="${TARGET_CONFIG_DIR}/coffee"

# Zsh Custom Paths Configuration
ZSHENV_FILE="${REAL_HOME}/.zshenv"
ZSH_CONFIG_DIR="${TARGET_CONFIG_DIR}/zsh"
ZSHRC_FILE="${ZSH_CONFIG_DIR}/.zshrc"

trap 'printf "%s%sERROR:%s Fallo en despliegue de configuraciones (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# ------------------------------------------------------------------------------
# Configuración del Entorno Zsh y PATH (~/.config/zsh)
# ------------------------------------------------------------------------------
setup_zsh_and_path() {
  printf "%b\n" "${BLD}${CYE}Configurando entorno Zsh personalizado ($ZDOTDIR) y PATH...${CNC}"

  # 1. Asegurar que Zsh busque sus configs en ~/.config/zsh
  local zshenv_line='export ZDOTDIR="$HOME/.config/zsh"'
  if [ -f "$ZSHENV_FILE" ]; then
    if ! grep -Fxq "$zshenv_line" "$ZSHENV_FILE"; then
      printf "\n# Added by coffee-dots ☕\n%s\n" "$zshenv_line" >>"$ZSHENV_FILE"
    fi
  else
    printf "# Added by coffee-dots ☕\n%s\n" "$zshenv_line" >"$ZSHENV_FILE"
  fi
  printf "%b\n" "${CGR}✓ Redirección ZDOTDIR configurada en ~/.zshenv${CNC}"

  # 2. Asegurar que exista la carpeta destino del binario coffee
  mkdir -p "$COFFEE_BIN_DIR"
  mkdir -p "$ZSH_CONFIG_DIR"

  # 3. Instalar zap
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --keep
}

# ------------------------------------------------------------------------------
# Vinculación Simbólica
# ------------------------------------------------------------------------------
create_symlink() {
  local source_path="$1"
  local target_path="$2"
  local target_dir
  target_dir=$(dirname "$target_path")

  mkdir -p "$target_dir"

  if [ -L "$target_path" ]; then
    rm "$target_path"
  elif [ -e "$target_path" ]; then
    printf "%b\n" "${CYE}⚠️  Detectado elemento real en ${target_path}. Creando respaldo...${CNC}"
    mv "$target_path" "${target_path}.bak"
  fi

  ln -s "$source_path" "$target_path"
}

# ------------------------------------------------------------------------------
# Despliegue por Autodetección Dinámica
# ------------------------------------------------------------------------------
deploy_dotfiles() {
  printf "%b\n" "${BLD}${CYE}Iniciando mapeo dinámico de coffee-dots...${CNC}"

  if [ ! -d "$REPO_CONFIG_DIR" ]; then
    printf "%b\n" "${CRE}❌ Error: No se encuentra la carpeta de configuraciones en ${REPO_CONFIG_DIR}${CNC}"
    return 1
  fi

  for item_path in "$REPO_CONFIG_DIR"/* "$REPO_CONFIG_DIR"/.*; do
    local item_name
    item_name=$(basename "$item_path")
    if [ "$item_name" == "." ] || [ "$item_name" == ".." ]; then
      continue
    fi

    [ -e "$item_path" ] || continue

    local target_path="${TARGET_CONFIG_DIR}/${item_name}"

    printf "%b" "${CYE}→ Vinculando estructura de: ${CBL}${item_name}${CNC} ... "
    create_symlink "$item_path" "$target_path"
    printf "%b\n" "${CGR}✓ Link listo${CNC}"
  done
}

# ------------------------------------------------------------------------------
# Mapeo Masivo de Mimetypes
# ------------------------------------------------------------------------------
setup_mimetypes() {
  if ! command -v xdg-mime &>/dev/null; then
    return 0
  fi

  printf "%b\n" "${BLD}${CYE}Estableciendo asociaciones masivas de archivos (Mimetypes)...${CNC}"

  sudo -u "${REAL_USER}" xdg-mime default org.gregorykoehler.ghostty.desktop inode/directory || true
  sudo -u "${REAL_USER}" xdg-mime default org.gnome.Evince.desktop application/pdf || true

  local img_types=(image/png image/jpeg image/gif image/webp image/bmp image/tiff)
  for type in "${img_types[@]}"; do
    sudo -u "${REAL_USER}" xdg-mime default imv.desktop "$type" || true
  done

  local video_types=(
    video/mp4 video/x-msvideo video/x-matroska video/x-flv video/x-ms-wmv
    video/mpeg video/ogg video/webm video/quicktime video/3gpp video/3gpp2
    video/x-ms-asf video/x-ogm+ogg video/x-theora+ogg application/ogg
  )
  for type in "${video_types[@]}"; do
    sudo -u "${REAL_USER}" xdg-mime default mpv.desktop "$type" || true
  done

  local text_types=(
    text/plain text/english text/x-makefile text/x-c++hdr text/x-c++src
    text/x-chdr text/x-csrc text/x-java text/x-moc text/x-pascal text/x-tcl
    text/x-tex application/x-shellscript text/x-c text/x-c++ application/xml text/xml
  )
  for type in "${text_types[@]}"; do
    sudo -u "${REAL_USER}" xdg-mime default nvim.desktop "$type" || true
  done

  printf "%b\n" "${CGR}✓ Todos los Mimetypes sincronizados bajo el usuario no-root.${CNC}"
}

# ------------------------------------------------------------------------------
# Ejecución Principal
# ------------------------------------------------------------------------------
main() {
  mkdir -p "$TARGET_CONFIG_DIR"

  mise use --global node

  setup_zsh_and_path
  deploy_dotfiles
  setup_mimetypes

  # Lanzadores (.desktop)
  ln -s ~/coffee-dots/applications/*.desktop ~/.local/share/applications 2>/dev/null || true
  ln -s ~/coffee-dots/applications/hidden/*.desktop ~/.local/share/applications 2>/dev/null || true

  # Recursos Visuales para Lanzadores
  ln -s ~/coffee-dots/applications/icons ~/.local/share/ 2>/dev/null || true

  # Refrescar base de datos de escritorio
  update-desktop-database "$REAL_HOME/.local/share/applications" 2>/dev/null || true

  # Corrección final de dueños en las rutas modificadas
  chown -R "${REAL_USER}:${REAL_USER}" "$TARGET_CONFIG_DIR"
  chown "$REAL_USER:$REAL_USER" "$ZSHENV_FILE" 2>/dev/null || true
  #permisos de ejecucion a los scripts
  find "$REAL_HOME"/.config/coffee -type d -exec chmod +x {} +

  # Give this user privileged input access for dictation tools + xbox controllers to work
sudo usermod -aG input ${USER}

#fast shutdown
sudo mkdir -p /etc/systemd/system.conf.d
sudo cp "$REAL_HOME/coffee-dots/default/systemd/faster-shutdown.conf" /etc/systemd/system.conf.d/10-faster-shutdown.conf
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo cp "$REAL_HOME/coffee-dots/default/systemd/user@.service.d/faster-shutdown.conf" /etc/systemd/system/user@.service.d/faster-shutdown.conf


sudo install -d /etc/systemd/system/plocate-updatedb.service.d
printf '%s\n' '[Unit]' 'ConditionACPower=true' | sudo tee /etc/systemd/system/plocate-updatedb.service.d/ac-only.conf >/dev/null
sudo systemctl daemon-reload

sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root "$OMARCHY_PATH/default/systemd/system-sleep/unmount-fuse" /usr/lib/systemd/system-sleep/

mkdir -p ~/Downloads ~/Pictures ~/Videos ~/.config/gtk-3.0

xdg-user-dirs-update --set TEMPLATES "$HOME"
xdg-user-dirs-update --set PUBLICSHARE "$HOME"
xdg-user-dirs-update --set DESKTOP "$HOME"

rmdir ~/Templates ~/Public ~/Desktop 2>/dev/null || true

touch ~/.config/gtk-3.0/bookmarks
for dir in Downloads Projects Pictures Videos; do
  printf 'file://%s/%s %s\n' "$HOME" "$dir" "$dir" >>~/.config/gtk-3.0/bookmarks
done

# Create pacman hook to restart walker after updates
sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/walker-restart.hook > /dev/null << EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = walker
Target = walker-debug
Target = elephant*

[Action]
Description = Restarting Walker services after system update
When = PostTransaction
Exec = $COFFEE_BIN_DIR/restart-walker
EOF

sudo systemctl enable --now iwd

elephant service enable
systemctl --user start elephant


  printf "\n%b\n" "${CGR}✓ [Fase 3] Despliegue de entorno, Zsh modular y mimetypes completado con éxito.${CNC}"
}

main "$@"
