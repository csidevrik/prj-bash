#!/bin/sh

# Verificar la distribucion actual
if [ -f /etc/lsb-release ]; then
    # Distribucion basada en Ubuntu
    DISTRO="ubuntu"
elif [ -f /etc/fedora-release ]; then
    # Distribucion basada en Fedora
    DISTRO="fedora"
else
    echo "No se pudo determinar la distribución actual"
    exit 1
fi

# Instalar las librerias según la distribucion
if [ "$DISTRO" = "ubuntu" ]; then
    # Instalar las librerias en Ubuntu
    sudo apt-get update
    sudo apt-get install -y curl git ncdu zsh htop screenfetch openssh-server openssl
elif [ "$DISTRO" = "fedora" ]; then
    # Instalar las librerias en Fedora 37
    sudo dnf update
    sudo dnf install -y curl git ncdu zsh htop screenfetch openssh-server openssl
    # Verificar la versión de Fedora
    VERSION=$(grep -oP '(?<=Fedora release )[0-9]+' /etc/fedora-release)
    if [ "$VERSION" = "37" ]; then
        # Instalar repositorios de RPM Fusion
        sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-37.noarch.rpm
        sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-37.noarch.rpm
fi