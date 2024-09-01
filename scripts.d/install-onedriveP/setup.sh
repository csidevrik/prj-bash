#!/bin/sh

#Variables
packages_ubuntu=("neovim" "curl" "git" "ncdu" "zsh" "htop" "screenfetch" "openssh-server" "openssl" "sqlite")
packages_fedora=("neovim" "curl" "git" "ncdu" "zsh" "htop" "screenfetch" "openssh-server" "openssl" "sqlite")

NAME_DRIVE_RCLONE=OneDriveP
NAME_DRIVE_FOLDER=OneDrivePAS
MOUNT_PATH_ONEDRIVEP="$HOME/$NAME_DRIVE_FOLDER"

NAME_SCRIPT_ONEDRIVE=rc-onedrivep
SCRIPT_PATH_ONEDRIVE="/usr/local/bin/$NAME_SCRIPT_ONEDRIVE"

NAME_SERVICE_RCLONE_ONEDRIVE="$NAME_SCRIPT_ONEDRIVE.service"
SERVICE_PATH_RCLONE_ONEDRIVE="/etc/systemd/system/$NAME_SERVICE_RCLONE_ONEDRIVE"

NAME_LOG_RCLONE_ONEDRIVE="$NAME_SCRIPT_ONEDRIVE.log"
LOG_PATH_RCLONE_ONEDRIVE="/var/log/$NAME_LOG_RCLONE_ONEDRIVE"

USER_NAME="$USER"
SYSTEMD_USER="$USER"


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


# ==================================================================================================
# FUNCTION SPACE
# ==================================================================================================

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

# Función para verificar si un folder existe o no en linux leyendo el primer parametro pasado, por el momento 
# esta funcion usa las variables globales ya haremos una especifica para leer todos los argumentos.
create_script_onedrive(){
    FILE_PATH="$1"
    if [ ! -f "$FILE_PATH" ]; then
        printf "${FMT_BLUE}Creando el directorio %s ya que no existe.${NC}\n" "$FILE_PATH"
        sudo bash -c "cat > $FILE_PATH" << EOF
#!/bin/bash
LOGFILE=${LOG_PATH_RCLONE_ONEDRIVE}
/usr/bin/rclone --vfs-cache-mode writes mount "${NAME_DRIVE_RCLONE}": ~/${NAME_DRIVE_FOLDER} &> ${LOG_PATH_RCLONE_ONEDRIVE} &
if [ \$? -eq 0 ]; then
    /usr/bin/notify-send "Microsoft OneDrive" "Microsoft OneDrive successfully mounted."
    printf "${FMT_GREEN}Mounted successfully" >> "${LOG_PATH_RCLONE_ONEDRIVE}"
else
    printf "${FMT_RED}Failed to mount OneDrive" >> "${LOG_PATH_RCLONE_ONEDRIVE}"
fi
EOF
        sudo chmod +x "$FILE_PATH"
    else
        printf "${FMT_BLUE}El script ya existe ${NC}\n" "$FILE_PATH"
    fi
}

# Función para eliminar el script de OneDrive
delete_script_onedrive(){
    if [ -f "$SCRIPT_PATH_ONEDRIVE" ]; then
        sudo rm -f "$SCRIPT_PATH_ONEDRIVE"
        printf "${FMT_GREEN}Script eliminado: %s${NC}\n" "$SCRIPT_PATH_ONEDRIVE"
    else
        printf "${FMT_RED}El script no existe: %s${NC}\n" "$SCRIPT_PATH_ONEDRIVE"
    fi
}


verify_folder_drive(){
    DIR_PATH="$1"
    if [ -d "$DIR_PATH" ]; then
        printf "${FMT_BLUE}El directorio ya existe ${NC}\n" "$DIR_PATH"
    else
        printf "${FMT_RED}El directorio %s no existe.${NC}\n" "$DIR_PATH"
        printf "${FMT_YELLOW}¿Deseas crearlo? (Y/N): ${NC}"
        read -r respuesta
        if [[ "$respuesta" =~ ^[Yy]$ ]]; then
            mkdir -p "$DIR_PATH"
            printf "${FMT_GREEN}El directorio %s ha sido creado.${NC}\n" "$DIR_PATH"
        else
            printf "${FMT_RED}El directorio %s no se ha creado.${NC}\n" "$DIR_PATH"
        fi
    fi
}

# Función para eliminar el directorio de montaje
delete_folder_drive(){
    if [ -d "$MOUNT_PATH_ONEDRIVEP" ]; then
        sudo rm -rf "$MOUNT_PATH_ONEDRIVEP"
        printf "${FMT_GREEN}Directorio eliminado: %s${NC}\n" "$MOUNT_PATH_ONEDRIVEP"
    else
        printf "${FMT_RED}El directorio no existe: %s${NC}\n" "$MOUNT_PATH_ONEDRIVEP"
    fi
}

# ==================================================================================================
# MAIN SPACE
# ==================================================================================================
main(){

    verify_folder_drive     $MOUNT_PATH_ONEDRIVEP
    create_script_onedrive  $SCRIPT_PATH_ONEDRIVE
    sleep 30
    delete_script_onedrive
    delete_folder_drive
}    



# **************************************************************************************************
# MAIN CALL
# **************************************************************************************************

#LLamada a la funcion principal (main)
main