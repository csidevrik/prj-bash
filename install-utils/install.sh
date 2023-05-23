#!/bin/bash

# Verificar la distribución actual
if [[ -f /etc/lsb-release ]]; then
    # Distribución basada en Ubuntu
    DISTRO="ubuntu"
elif [[ -f /etc/fedora-release ]]; then
    # Distribución basada en Fedora
    DISTRO="fedora"
else
    echo "No se pudo determinar la distribución actual"
    exit 1
fi

# Instalar las librerías según la distribución
if [[ $DISTRO == "ubuntu" ]]; then
    # Instalar las librerías en Ubuntu
    sudo apt-get update
    sudo apt-get install -y curl zsh ncdu git 
elif [[ $DISTRO == "fedora" ]]; then
    # Instalar las librerías en Fedora
    sudo dnf update
    sudo dnf install -y curl zsh ncdu git
fi