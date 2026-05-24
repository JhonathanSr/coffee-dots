#!/bin/bash

# ==============================================================================
# SCRIPT: MIME Types & Desktop Applications Configuration
# DESCRIPCIÓN: Define las aplicaciones predeterminadas para diferentes tipos de 
#              archivos (MIME) y despliega archivos .desktop personalizados para
#              la integración con lanzadores como Walker.
# DEPENDENCIAS: xdg-utils, coreutils, desktop-file-utils.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Configuración de Asociaciones de Archivos (MIME Types) ---

# Imágenes: Establecemos feh como el visor ligero predeterminado.
xdg-mime default feh.desktop image/png
xdg-mime default feh.desktop image/jpeg
xdg-mime default feh.desktop image/gif
xdg-mime default feh.desktop image/webp
xdg-mime default feh.desktop image/bmp
xdg-mime default feh.desktop image/tiff

# Documentos: Evince para la lectura de PDFs.
xdg-mime default org.gnome.Evince.desktop application/pdf

# Video y Multimedia: mpv como motor principal para todos los formatos conocidos.
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/x-flv
xdg-mime default mpv.desktop video/x-ms-wmv
xdg-mime default mpv.desktop video/mpeg
xdg-mime default mpv.desktop video/ogg
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/quicktime
xdg-mime default mpv.desktop video/3gpp
xdg-mime default mpv.desktop video/3gpp2
xdg-mime default mpv.desktop video/x-ms-asf
xdg-mime default video/x-ogm+ogg
xdg-mime default video/x-theora+ogg
xdg-mime default application/ogg

# Open text files with nvim
xdg-mime default nvim.desktop text/plain
xdg-mime default nvim.desktop text/english
xdg-mime default nvim.desktop text/x-makefile
xdg-mime default nvim.desktop text/x-c++hdr
xdg-mime default nvim.desktop text/x-c++src
xdg-mime default nvim.desktop text/x-chdr
xdg-mime default nvim.desktop text/x-csrc
xdg-mime default nvim.desktop text/x-java
xdg-mime default nvim.desktop text/x-moc
xdg-mime default nvim.desktop text/x-pascal
xdg-mime default nvim.desktop text/x-tcl
xdg-mime default nvim.desktop text/x-tex
xdg-mime default nvim.desktop application/x-shellscript
xdg-mime default nvim.desktop text/x-c
xdg-mime default nvim.desktop text/x-c++
xdg-mime default nvim.desktop application/xml
xdg-mime default nvim.desktop text/xml


# --- Despliegue de Lanzadores (.desktop) ---
# Copiamos los archivos de escritorio personalizados y los ocultos para 
# limpiar el menú de aplicaciones y mejorar la integración con el sistema.
cp "$HOME/coffee-dots/applications/"*.desktop ~/.local/share/applications
cp "$HOME/coffee-dots/applications/hidden/"*.desktop ~/.local/share/applications

# --- Recursos Visuales para Lanzadores ---
# Corregimos la falta de iconos en Walker u otros lanzadores TUI/GUI 
# moviendo los activos necesarios al directorio local del usuario.
cp -r "$HOME/coffee-dots/applications/icons" ~/.local/share/

# --- Finalización y Actualización ---
# Refrescamos la base de datos de aplicaciones para que los cambios en los 
# archivos .desktop y las asociaciones MIME se apliquen de inmediato.
update-desktop-database ~/.local/share/applications
