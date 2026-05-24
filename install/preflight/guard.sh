#!/bin/bash

abort() {
  echo -e "\e[31mInstalando requisitos: $1\e[0m"
  echo
  gum confirm "Desea continuar?" || exit 1
}

# No debe ser ejecutado como root
[ "$EUID" -eq 0 ] && abort "No debe ser ejecutado como root"

# Debe ser una instalación limpia de Arch Linux en x86_64
[ "$(uname -m)" != "x86_64" ] && abort "x86_64 CPU"

# No debe tener Gnome o KDE ya instalados ni otro gestor de ventanas
pacman -Qe gnome-shell &>/dev/null && abort "Fresh + Vanilla Arch"
pacman -Qe plasma-desktop &>/dev/null && abort "Fresh + Vanilla Arch"

# Pasaron todas las pruebas
echo "Guards: OK"