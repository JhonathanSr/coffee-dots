#!/bin/bash

# ==============================================================================
# SCRIPT: Development Tools & Toolchains Setup
# DESCRIPCIÓN: Instalación de compiladores, lenguajes de programación y utilidades
#              de productividad para el flujo de trabajo de ingeniería de software.
# DEPENDENCIAS: paru, gcc, python, go, rust, github-cli.
# AUTOR: Jhonathan Ruiz (Coffee-Dots)
# FECHA: 15/05/2026
# ==============================================================================

# --- Herramientas de Compilación (Build Essentials) ---
# Instalamos los motores de construcción necesarios para compilar software desde
# fuentes, kernels personalizados o módulos de AUR.
# ninja: Alternativa de alto rendimiento a make, usada por muchos proyectos modernos.
paru -S --noconfirm --needed gcc cmake make ninja

# --- Lenguajes de Programación y Runtimes ---
# Despliegue de los stacks tecnológicos base para el desarrollo multiplataforma.
# clang/llvm: Suite de compiladores C/C++/Obj-C de alto rendimiento.
# python-pip: Gestión de paquetes para scripts y herramientas Python.
# go/rust: Lenguajes de sistemas modernos para alto rendimiento y seguridad.
paru -S --noconfirm --needed mise clang llvm 
mise use -g python
mise use -g go
mise use -g rust

# --- Productividad y Gestión de Proyectos Git ---
# github-cli (gh): Interacción con GitHub (PRs, Issues, Repos) sin salir de la shell.
# lazygit: Interfaz TUI visual para gestionar commits, ramas y rebase de forma fluida.
paru -S --noconfirm --needed github-cli lazygit

# --- Contenedores ---
paru -S --noconfirm --needed docker docker-compose lazydocker
