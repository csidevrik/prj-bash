#!/bin/sh

#Variables
packages_ubuntu="neovim curl git ncdu zsh htop screenfetch openssh-server openssl sqlite3"
packages_fedora="neovim curl git ncdu zsh htop screenfetch openssh-server openssl sqlite"

# Colores de formato
FMT_RESET=$(tput sgr0)
FMT_BOLD=$(tput bold)
FMT_RED=$(tput setaf 1)
FMT_GREEN=$(tput setaf 2)
FMT_YELLOW=$(tput setaf 3)
FMT_PURPLE=$(tput setaf 5)
FMT_BLUE=$(tput setaf 4)

# Arrays para rastrear instalación
INSTALLED_PACKAGES=""
FAILED_PACKAGES=""

# Función para imprimir mensajes de éxito
print_success() {
  printf '\n%s%s%s\n' "${FMT_GREEN}${FMT_BOLD}" "¡Proceso de instalación completado!" "${FMT_RESET}"

  if [ -n "$INSTALLED_PACKAGES" ]; then
    printf '%sLos siguientes paquetes se instalaron correctamente:\n' "${FMT_GREEN}"
    for pkg in $INSTALLED_PACKAGES; do
      printf '  ✓ %s\n' "$pkg"
    done
  fi

  if [ -n "$FAILED_PACKAGES" ]; then
    printf '%sLos siguientes paquetes NO pudieron instalarse:\n' "${FMT_RED}"
    for pkg in $FAILED_PACKAGES; do
      printf '  ✗ %s\n' "$pkg"
    done
    printf '%sVerifica si están disponibles en tu distribución o usa nombres alternativos.\n' "${FMT_YELLOW}"
  fi

  printf '%s\n' "${FMT_RESET}"
  printf '%sEjecuta "zsh" para probar tu nuevo shell.\n' "${FMT_YELLOW}"
  printf '%sSi prefieres mantener tu shell actual, reinicia tu sesión para aplicar los cambios.\n' "${FMT_YELLOW}"
  printf '%s¡Disfruta de tu nueva configuración de shell!\n' "${FMT_RESET}"
}

# Función para instalar paquetes individualmente en Ubuntu
install_ubuntu_packages() {
  printf '%sActualizando lista de paquetes...\n' "${FMT_YELLOW}"
  sudo apt-get update || {
    printf '%sError al actualizar repositorios\n' "${FMT_RED}"
    return 1
  }

  printf '%sInstalando paquetes...\n' "${FMT_YELLOW}"

  for pkg in $packages_ubuntu; do
    printf '%sIntentando instalar: %s\n' "${FMT_BLUE}" "$pkg"

    # Verificar si el paquete existe
    if apt-cache search "^${pkg}$" 2>/dev/null | grep -q .; then
      sudo apt-get install -y "$pkg" 2>/dev/null
      if [ $? -eq 0 ]; then
        INSTALLED_PACKAGES="$INSTALLED_PACKAGES $pkg"
        printf '%s✓ %s instalado correctamente\n' "${FMT_GREEN}" "$pkg"
      else
        FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
        printf '%s✗ Error al instalar %s\n' "${FMT_RED}" "$pkg"
      fi
    else
      FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
      printf '%s✗ Paquete %s no encontrado en los repositorios\n' "${FMT_RED}" "$pkg"
    fi
  done
}

# Función para instalar paquetes individualmente en Fedora
install_fedora_packages() {
  printf '%sActualizando sistema...\n' "${FMT_YELLOW}"
  sudo dnf update -y || {
    printf '%sError al actualizar sistema\n' "${FMT_RED}"
    return 1
  }

  printf '%sInstalando paquetes...\n' "${FMT_YELLOW}"

  for pkg in $packages_fedora; do
    printf '%sIntentando instalar: %s\n' "${FMT_BLUE}" "$pkg"

    # Verificar si el paquete existe
    if dnf search "$pkg" 2>/dev/null | grep -q "^${pkg}.*"; then
      sudo dnf install -y "$pkg" 2>/dev/null
      if [ $? -eq 0 ]; then
        INSTALLED_PACKAGES="$INSTALLED_PACKAGES $pkg"
        printf '%s✓ %s instalado correctamente\n' "${FMT_GREEN}" "$pkg"
      else
        FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
        printf '%s✗ Error al instalar %s\n' "${FMT_RED}" "$pkg"
      fi
    else
      FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
      printf '%s✗ Paquete %s no encontrado en los repositorios\n' "${FMT_RED}" "$pkg"
    fi
  done
}

# Función para instalar repositorios de RPM Fusion en Fedora
install_rpmfusion_repos() {
    version=$1
    printf '%sInstalando repositorios RPM Fusion...\n' "${FMT_YELLOW}"

    sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${version}.noarch.rpm" 2>/dev/null
    sudo dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${version}.noarch.rpm" 2>/dev/null

    if [ $? -eq 0 ]; then
      printf '%s✓ Repositorios RPM Fusion instalados\n' "${FMT_GREEN}"
    else
      printf '%s✗ Error al instalar repositorios RPM Fusion\n' "${FMT_RED}"
    fi
}

main(){
    # Verificar la distribucion actual
    if [ -f /etc/lsb-release ]; then
        DISTRO="ubuntu"
        printf "%s%s%sEstas en una distro de Ubuntu%s\n" "${FMT_RESET}" "${FMT_PURPLE}" "${FMT_BOLD}" "${FMT_RESET}"
    elif [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
        printf "%s%sEstas en una distro de Fedora%s\n" "${FMT_BLUE}" "${FMT_BOLD}" "${FMT_RESET}"
    else
        printf "%s%s%sNo se pudo determinar la distribución actual%s\n" "${FMT_RESET}" "${FMT_RED}" "${FMT_BOLD}" "${FMT_RESET}"
        exit 1
    fi

    # Instalar las librerias según la distribucion
    if [ "$DISTRO" = "ubuntu" ]; then
        install_ubuntu_packages
    elif [ "$DISTRO" = "fedora" ]; then
        install_fedora_packages

        # Verificar la versión de Fedora
        VERSION=$(grep -oP '(?<=Fedora release )[0-9]+' /etc/fedora-release 2>/dev/null || awk '{print $3}' /etc/fedora-release)

        # Instalar repositorios de RPM Fusion si es versión 37 o superior
        if [ "$VERSION" -ge 37 ] 2>/dev/null; then
            install_rpmfusion_repos "$VERSION"
        fi
    fi

    # Llamada a la función de impresión de éxito
    print_success
}

#LLamada a la funcion principal (main)
main