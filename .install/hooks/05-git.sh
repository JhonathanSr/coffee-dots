#!/usr/bin/env bash
# Componente: Configuración y Aliases Globales de Git

CYE=$(tput setaf 3); CGR=$(tput setaf 2); BLD=$(tput bold); CNC=$(tput sgr0)

printf "%b\n" "${BLD}${CYE}Inyectando directivas y aliases globales de Git...${CNC}"
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global core.editor nvim

printf "%b\n" "${CGR}✓ Aliases de Git configurados correctamente.${CNC}"