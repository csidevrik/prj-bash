#!/bin/sh

#Variables
packages_ubuntu=("neovim" "curl" "git" "ncdu" "zsh" "htop" "screenfetch" "openssh-server" "openssl" "sqlite")
packages_fedora=("neovim" "curl" "git" "ncdu" "zsh" "htop" "screenfetch" "openssh-server" "openssl" "sqlite")

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
  printf '%s¡Disfruta de tu nueva configuración de sol!\n' "${FMT_RESET}"
}

# Función para instalar repositorios de RPM Fusion en Fedora
install_rpmfusion_repos() {
    local version=$1
    sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$version.noarch.rpm"
    sudo dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$version.noarch.rpm"
}


main(){
    # Llamada a la función de impresión de éxito
    print_success
}    

#LLamada a la funcion principal (main)
main