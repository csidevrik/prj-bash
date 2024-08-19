#!/bin/sh

#Variables
packages_ubuntu=("neovim" "curl" "git" "ncdu" "zsh" "htop" "screenfetch" "openssh-server" "openssl" "sqlite")
packages_fedora=("neovim" "curl" "git" "ncdu" "zsh" "htop" "screenfetch" "openssh-server" "openssl" "sqlite")

pack_neovim="neovim"
pack_curl="curl"
pack_git="git"
pack_ncdu="ncdu"
pack_zsh="zsh"
pack_htop="htop"
pack_screenfetch="screenfetch"
pack_openssh="openssh-server"
pack_openssl="openssl"
pack_sqlite="sqlite"


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
  printf '%s\n' "${packages_ubuntu[@]}"  # Si es Ubuntu, muestra los paquetes
  printf '%s\n' "${packages_fedora[@]}"  # Si es Fedora, muestra los paquetes
  printf '%s\n' "${FMT_RESET}"
  printf '%sEjecuta "zsh" para probar tu nuevo shell.\n' "${FMT_YELLOW}"
  printf '%sSi prefieres mantener tu shell actual, reinicia tu sesión para aplicar los cambios.\n' "${FMT_YELLOW}"
  printf '%s¡Disfruta de tu nueva configuración de shell!\n' "${FMT_RESET}"
}

# Función para instalar repositorios de RPM Fusion en Fedora
install_rpmfusion_repos() {
    local version=$1
    sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$version.noarch.rpm"
    sudo dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$version.noarch.rpm"
}


main(){
    # Verificar la distribucion actual
    if [ -f /etc/lsb-release ]; then {
        # Distribucion basada en Ubuntu
        DISTRO="ubuntu"
        printf "${FMT_RESET}${FMT_PURPLE}${FMT_BOLD}Estas en una distro de Ubuntu${FMT_RESET}\n"
    }
    elif [ -f /etc/fedora-release ]; then {
        # Distribucion basada en Fedora
        DISTRO="fedora"
        printf "${FMT_BLUE}${FMT_BOLD}Estas en una distro de Fedora${FMT_RESET}\n"
    }
    else
        printf "${FMT_RESET}${FMT_RED}${FMT_BOLD}No se pudo determinar la distribución actual${FMT_RESET}\n"
        exit 1
    fi
    # Instalar las librerias según la distribucion
    if [ "$DISTRO" = "ubuntu" ]; then
        # Instalar las librerias en Ubuntu
        sudo apt-get update
        # sudo apt-get install -y "${packages_ubuntu[@]}"
        sudo apt install -y $pack_curl $pack_git $pack_htop $pack_ncdu $pack_neovim \
                            $pack_openssh $pack_openssl $pack_screenfetch $pack_sqlite \
                            $pack_zsh 
    elif [ "$DISTRO" = "fedora" ]; then
        # Instalar las librerias en Fedora
        sudo dnf update
        # sudo dnf install -y "${packages_fedora[@]}"
        sudo dnf install -y $pack_curl $pack_git $pack_htop $pack_ncdu $pack_neovim \
                            $pack_openssh $pack_openssl $pack_screenfetch $pack_sqlite \
                            $pack_zsh 
                            
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

    # Llamada a la función de impresión de éxito
    print_success
}    




#LLamada a la funcion principal (main)
main