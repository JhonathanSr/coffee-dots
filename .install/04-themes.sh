#!/usr/bin/env bash
# ==============================================================================
# Fase: 04-themes | Componente: Gestión Estética (Fonts, GTK, QT, Kvantum)
# Descripción: Centraliza la consistencia visual de coffee-dots sin interfaces gráficas.
# ==============================================================================

CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); CBL=$(tput setaf 4); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

mkdir -p "$(dirname "$ERROR_LOG")"
trap 'printf "%s%sERROR:%s Fallo en la fase de temas (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# ------------------------------------------------------------------------------
# 1. Consistencia GTK 3/4
# ------------------------------------------------------------------------------
setup_gtk_theme() {
  printf "%b\n" "${BLD}${CYE}Configurando consistencia GTK (Modo Oscuro)...${CNC}"
  local gtk_3="$REAL_HOME/.config/gtk-3.0/settings.ini"
  local gtk_4="$REAL_HOME/.config/gtk-4.0/settings.ini"
  
  for file in "$gtk_3" "$gtk_4"; do
    sudo -u "${REAL_USER}" mkdir -p "$(dirname "$file")"
    if [ ! -f "$file" ]; then
      printf "[Settings]\ngtk-application-prefer-dark-theme=1\n" | sudo -u "${REAL_USER}" tee "$file" >/dev/null
    else
      if ! grep -q "^\[Settings\]" "$file"; then sed -i '1i\[Settings\]' "$file"; fi
      if grep -q "gtk-application-prefer-dark-theme" "$file"; then
        sed -i 's/gtk-application-prefer-dark-theme.*/gtk-application-prefer-dark-theme=1/g' "$file"
      else
        sed -i '/^\[Settings\]/a gtk-application-prefer-dark-theme=1' "$file"
      fi
    fi
  done
}

# ------------------------------------------------------------------------------
# 2. Automatización Headless de Kvantum (Para QT_STYLE_OVERRIDE)
# ------------------------------------------------------------------------------
setup_kvantum_theme() {
  printf "%b\n" "${BLD}${CYE}Configurando Kvantum de forma headless...${CNC}"
  local kvantum_conf="$REAL_HOME/.config/Kvantum/kvantum.kvconfig"
  
  sudo -u "${REAL_USER}" mkdir -p "$(dirname "$kvantum_conf")"
  
  # Forzamos un tema oscuro nativo de Kvantum (ej: KvFlatDark o KvDark)
  # Si en tus coffee-dots tienes un tema personalizado, cambia 'KvFlatDark' por el tuyo.
  cat <<EOF | sudo -u "${REAL_USER}" tee "$kvantum_conf" >/dev/null
[General]
theme=KvFlatDark
EOF
}

# ------------------------------------------------------------------------------
# 3. Automatización Headless de QT5CT / QT6CT (Para QT_QPA_PLATFORMTHEME)
# ------------------------------------------------------------------------------
setup_qt_ct() {
  printf "%b\n" "${BLD}${CYE}Configurando perfiles de qt5ct y qt6ct...${CNC}"
  local qt5_conf="$REAL_HOME/.config/qt5ct/qt5ct.conf"
  local qt6_conf="$REAL_HOME/.config/qt6ct/qt6ct.conf"
  
  for file in "$qt5_conf" "$qt6_conf"; do
    sudo -u "${REAL_USER}" mkdir -p "$(dirname "$file")"
    
    # Inyectamos la configuración para que el backend use Kvantum y paleta oscura
    cat <<EOF | sudo -u "${REAL_USER}" tee "$file" >/dev/null
[Appearance]
custom_palette=true
icon_theme=Adwaita-dark
style=kvantum
EOF
  done
}

# ------------------------------------------------------------------------------
# Ejecución Principal
# ------------------------------------------------------------------------------
main() {
  printf "%b\n\n" "${CBL}${BLD}[Coffee-Dots] Iniciando Fase 4: Automatización Estética CLI...${CNC}"
  
  setup_gtk_theme
  setup_kvantum_theme
  setup_qt_ct
  
  # Forzar recarga en la sesión viva si gsettings está disponible
  if command -v gsettings &>/dev/null; then
    sudo -u "${REAL_USER}" gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>>"$ERROR_LOG" || true
  fi
  
  # Corregir la propiedad de todo lo alterado en .config
  chown -R "${REAL_USER}:${REAL_USER}" "$REAL_HOME/.config/gtk-"* "$REAL_HOME/.config/Kvantum" "$REAL_HOME/.config/qt"* 2>>"$ERROR_LOG" || true

  printf "\n%b\n" "${CGR}✓ [Fase 4] Entornos GTK y QT unificados al modo oscuro vía CLI.${CNC}"
}

main "$@"