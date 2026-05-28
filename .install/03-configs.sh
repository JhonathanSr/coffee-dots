#!/usr/bin/env bash
# ==============================================================================
# Fase: 03-configs | Componente: Despliegue Automatizado de Dotfiles (Symlinks)
# Descripción: Detecta dinámicamente el software en la carpeta config/ del 
#              repositorio y mapea de forma masiva los MIME types del sistema.
# ==============================================================================

CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); CBL=$(tput setaf 4); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

# Rutas base del ecosistema coffee-dots
REPO_CONFIG_DIR="${REAL_HOME}/coffee-dots/config"
TARGET_CONFIG_DIR="${REAL_HOME}/.config"

trap 'printf "%s%sERROR:%s Fallo en despliegue de configuraciones (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# ------------------------------------------------------------------------------
# Vinculación Simbólica Quirúrgica y Segura
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
# Despliegue por Autodetección Dinámica (Mantenimiento Cero)
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
# Mapeo Masivo de Mimetypes (Asociaciones de tu suite de Apps)
# ------------------------------------------------------------------------------
setup_mimetypes() {
  if ! command -v xdg-mime &>/dev/null; then
    return 0
  fi

  printf "%b\n" "${BLD}${CYE}Estableciendo asociaciones masivas de archivos (Mimetypes)...${CNC}"

  # 1. Directorios -> Ghostty
  sudo -u "${REAL_USER}" xdg-mime default org.gregorykoehler.ghostty.desktop inode/directory || true

  # 2. Documentos PDF -> Evince
  sudo -u "${REAL_USER}" xdg-mime default org.gnome.Evince.desktop application/pdf || true

  # 3. Imágenes -> imv (Visor ligero de tu lista base)
  local img_types=(image/png image/jpeg image/gif image/webp image/bmp image/tiff)
  for type in "${img_types[@]}"; do
    sudo -u "${REAL_USER}" xdg-mime default imv.desktop "$type" || true
  done

  # 4. Video y Multimedia -> mpv
  local video_types=(
    video/mp4 video/x-msvideo video/x-matroska video/x-flv video/x-ms-wmv 
    video/mpeg video/ogg video/webm video/quicktime video/3gpp video/3gpp2 
    video/x-ms-asf video/x-ogm+ogg video/x-theora+ogg application/ogg
  )
  for type in "${video_types[@]}"; do
    sudo -u "${REAL_USER}" xdg-mime default mpv.desktop "$type" || true
  done

  # 5. Código y Texto Plano -> Neovim
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

  deploy_dotfiles
  setup_mimetypes


# --- Despliegue de Lanzadores (.desktop) ---
# Copiamos los archivos de escritorio personalizados y los ocultos para 
# limpiar el menú de aplicaciones y mejorar la integración con el sistema.
  ln -s "$HOME/coffee-dots/applications/"*.desktop ~/.local/share/applications
  ln -s "$HOME/coffee-dots/applications/hidden/"*.desktop ~/.local/share/applications

# --- Recursos Visuales para Lanzadores ---
# Corregimos la falta de iconos en Walker u otros lanzadores TUI/GUI 
# moviendo los activos necesarios al directorio local del usuario.
  ln -s "$HOME/coffee-dots/applications/icons" ~/.local/share/

# --- Finalización y Actualización ---
# Refrescamos la base de datos de aplicaciones para que los cambios en los 
# archivos .desktop y las asociaciones MIME se apliquen de inmediato.
  update-desktop-database ~/.local/share/applications

  
  chown -R "${REAL_USER}:${REAL_USER}" "$TARGET_CONFIG_DIR"
  printf "\n%b\n" "${CGR}✓ [Fase 3] Despliegue de entorno y mimetypes completado con éxito.${CNC}"
}

main "$@"