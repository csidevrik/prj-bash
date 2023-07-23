#!/bin/sh

#Variables
packages_ubuntu=("neovim" "curl" "git" "ncdu" "zsh" "htop" "screenfetch" "openssh-server" "openssl")
packages_fedora=("neovim" "curl" "git" "ncdu" "zsh" "htop" "screenfetch" "openssh-server" "openssl")

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

# Función para instalar repositorios de RPM Fusion en Fedora
install_rpmfusion_repos() {
    local version=$1
    sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$version.noarch.rpm"
    sudo dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$version.noarch.rpm"
}
# Instalar las librerias según la distribucion
if [ "$DISTRO" = "ubuntu" ]; then
    # Instalar las librerias en Ubuntu
    sudo apt-get update
    sudo apt-get install -y "${packages_ubuntu[@]}"
elif [ "$DISTRO" = "fedora" ]; then
    # Instalar las librerias en Fedora
    sudo dnf update
    sudo dnf install -y "${packages_fedora[@]}"
    # Verificar la versión de Fedora
    VERSION=$(grep -oP '(?<=Fedora release )[0-9]+' /etc/fedora-release)
    if [ "$VERSION" = "37" ]; then
        # Instalar repositorios de RPM Fusion
        install_rpmfusion_repos "$VERSION"
    fi
    if [ "$VERSION" = "38" ]; then
        # Instalar repositorios de RPM Fusion
        install_rpmfusion_repos "$VERSION"

    fi
fi