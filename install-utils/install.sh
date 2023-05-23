#!/bin/bash

# Verificar la distribucion actual
if `[[ -f /etc/lsb-release ]]`; then
    # Distribución basada en Ubuntu
    DISTRO="ubuntu"
elif `[[ -f /etc/fedora-release ]]`; then
    # Distribución basada en Fedora
    DISTRO="fedora"
else
    echo "No se pudo determinar la distribución actual"
    exit 1
fi

# Instalar las librerias según la distribucion
if `[[ $DISTRO == "ubuntu" ]]`; then
    # Instalar las librerias en Ubuntu
    sudo apt-get update
    sudo apt-get install -y curl zsh ncdu git htop
elif `[[ $DISTRO == "fedora" ]]`; then
    # Instalar las librerias en Fedora
    sudo dnf update
    sudo dnf install -y curl zsh ncdu git htop
fi