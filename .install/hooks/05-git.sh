#!/usr/bin/env bash
# Componente: Configuración y Aliases Globales de Git

CYE=$(tput setaf 3); CGR=$(tput setaf 2); BLD=$(tput bold); CNC=$(tput sgr0)

printf "%b\n" "${BLD}${CYE}Inyectando directivas y aliases globales de Git...${CNC}"

# ==========================================
# Set identification from install inputs
# ==========================================

# 1. Solicitar y configurar el Nombre de Usuario
if [[ -z ${USER_NAME//[[:space:]]/} ]]; then
  read -r -p "Introduce tu nombre para Git (ej. Jhonathan): " USER_NAME
fi

# 2. Solicitar y configurar el Correo Electrónico
if [[ -z ${USER_EMAIL//[[:space:]]/} ]]; then
  read -r -p "Introduce tu email para Git (ej. tu@email.com): " USER_EMAIL
fi

# Validar que no se haya introducido una cadena vacía tras el prompt
if [[ -n ${USER_NAME//[[:space:]]/} ]]; then
  git config --global user.name "$USER_NAME"
else
  echo "Log: No se configuró user.name (entrada vacía)."
fi

if [[ -n ${USER_EMAIL//[[:space:]]/} ]]; then
  git config --global user.email "$USER_EMAIL"
else
  echo "Log: No se configuró user.email (entrada vacía)."
fi


git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global core.editor nvim

printf "%b\n" "${CGR}✓ Aliases de Git configurados correctamente.${CNC}"