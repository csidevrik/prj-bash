#!/bin/sh

# Variables - sin arrays, solo strings separadas por espacios
packages="neovim curl git ncdu zsh htop screenfetch openssh-server openssl sqlite"

# Colores de formato
FMT_RESET=$(tput sgr0)
FMT_BOLD=$(tput bold)
FMT_RED=$(tput setaf 1)
FMT_GREEN=$(tput setaf 2)
FMT_YELLOW=$(tput setaf 3)
FMT_PURPLE=$(tput setaf 5)
FMT_BLUE=$(tput setaf 4)

# Función para imprimir mensajes de éxito
print_success() {
  printf '\n%s%s%s\n' "${FMT_GREEN}${FMT_BOLD}" "¡Instalación exitosa!" "${FMT_RESET}"
  printf '%sAhora tienes instalados los siguientes paquetes:\n' "${FMT_YELLOW}"
  
  # Imprimir paquetes sin usar arrays
  for pkg in $packages; do
    printf '  - %s\n' "$pkg"
  done
  
  printf '%s\n' "${FMT_RESET}"
  printf '%sEjecuta "zsh" para probar tu nuevo shell.\n' "${FMT_YELLOW}"
  printf '%sSi prefieres mantener tu shell actual, reinicia tu sesión para aplicar los cambios.\n' "${FMT_YELLOW}"
  printf '%s¡Disfruta de tu nueva configuración de shell!\n' "${FMT_RESET}"
}

# Función para instalar repositorios de RPM Fusion en Fedora
install_rpmfusion_repos() {
    version=$1
    sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${version}.noarch.rpm"
    sudo dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${version}.noarch.rpm"
}

main() {
    # Verificar la distribución actual
    if [ -f /etc/lsb-release ]; then
        # Distribución basada en Ubuntu
        DISTRO="ubuntu"
        printf '%s%s%sEstás en una distro de Ubuntu%s\n' "${FMT_RESET}" "${FMT_PURPLE}" "${FMT_BOLD}" "${FMT_RESET}"
    elif [ -f /etc/fedora-release ]; then
        # Distribución basada en Fedora
        DISTRO="fedora"
        printf '%s%sEstás en una distro de Fedora%s\n' "${FMT_BLUE}" "${FMT_BOLD}" "${FMT_RESET}"
    else
        printf '%s%s%sNo se pudo determinar la distribución actual%s\n' "${FMT_RESET}" "${FMT_RED}" "${FMT_BOLD}" "${FMT_RESET}"
        exit 1
    fi
    
    # Instalar las librerías según la distribución
    if [ "$DISTRO" = "ubuntu" ]; then
        # Instalar las librerías en Ubuntu
        sudo apt-get update
        # shellcheck disable=SC2086
        sudo apt-get install -y $packages
    elif [ "$DISTRO" = "fedora" ]; then
        # Instalar las librerías en Fedora
        sudo dnf update
        # shellcheck disable=SC2086
        sudo dnf install -y $packages
                            
        # Verificar la versión de Fedora
        VERSION=$(grep -oP '(?<=Fedora release )[0-9]+' /etc/fedora-release 2>/dev/null || awk '{print $3}' /etc/fedora-release)
        
        # Instalar repositorios de RPM Fusion si es versión 37 o 38
        if [ "$VERSION" = "37" ] || [ "$VERSION" = "38" ]; then
            install_rpmfusion_repos "$VERSION"
        fi
    fi

    # Llamada a la función de impresión de éxito
    print_success
}

# Llamada a la función principal (main)
main