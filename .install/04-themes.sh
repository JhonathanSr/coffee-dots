#!/usr/bin/env bash
# ==============================================================================
# Fase: 04-themes | Componente: Gestión Estética (Fonts, Temas GTK/QT y Iconos)
# Descripción: Centraliza la regeneración de caché de fuentes y la consistencia
#              visual de la suite gráfica de coffee-dots.
# ==============================================================================

CRE=$(tput setaf 1); CYE=$(tput setaf 3); CGR=$(tput setaf 2); CBL=$(tput setaf 4); BLD=$(tput bold); CNC=$(tput sgr0)
ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")

trap 'printf "%s%sERROR:%s Fallo en la fase de temas (Línea $LINENO)\n" "${CRE}" "${BLD}" "${CNC}" >&2' ERR

# ------------------------------------------------------------------------------
# 1. Fuentes del Sistema (Fontconfig)
# ------------------------------------------------------------------------------
refresh_fonts() {
  printf "%b\n" "${BLD}${CYE}Actualizando la caché de fuentes (fontconfig)...${CNC}"
  
  # Si tienes fuentes personalizadas en tu repo (ej: coffee-dots/assets/fonts)
  # las podemos enlazar aquí a ~/.local/share/fonts de forma dinámica.
  
  sudo -u "${REAL_USER}" fc-cache -fv >/dev/null 2>>"$ERROR_LOG"
  printf "%b\n" "${CGR}✓ Caché de fuentes reconstruida.${CNC}"
}

# ------------------------------------------------------------------------------
# 2. Consistencia GTK 3/4 (Para apps como Pinta, Obsidian, etc.)
# ------------------------------------------------------------------------------
setup_gtk_theme() {
  printf "%b\n" "${BLD}${CYE}Configurando preferencias de modo oscuro global (GTK)...${CNC}"
  
  # Forzar esquemas oscuros de forma nativa sin romper configs de usuario
  local gtk_settings="${REAL_HOME}/.config/gtk-3.0/settings.ini"
  local gtk_settings_4="${REAL_HOME}/.config/gtk-4.0/settings.ini"
  
  for settings_file in "$gtk_settings" "$gtk_settings_4"; do
    mkdir -p "$(dirname "$settings_file")"
    if [ ! -f "$settings_file" ] || ! grep -q "gtk-application-prefer-dark-theme" "$settings_file" 2>/dev/null; then
      printf "[Settings]\ngtk-application-prefer-dark-theme=1\n" > "$settings_file"
    fi
  done
  
  chown -R "${REAL_USER}:${REAL_USER}" "${REAL_HOME}/.config/gtk-"*
  printf "%b\n" "${CGR}✓ Preferencia de modo oscuro GTK inyectada.${CNC}"
}

# ------------------------------------------------------------------------------
# Ejecución Principal
# ------------------------------------------------------------------------------
main() {
  printf "%b\n\n" "${CBL}${BLD}[Coffee-Dots] Iniciando Fase 4: Personalización Estética...${CNC}"
  
  refresh_fonts
  setup_gtk_theme
  
  printf "\n%b\n" "${CGR}✓ [Fase 4] Estética y consistencia visual aplicadas con éxito.${CNC}"
}

main "$@"