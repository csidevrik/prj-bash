#!/bin/sh

# ==================================================================================================
# VARIABLE SPACE
# ==================================================================================================

NAME_DRIVE_RCLONE=OneDriveP
NAME_DRIVE_FOLDER=OneDriveP
MOUNT_PATH_DRIVE="$HOME/$NAME_DRIVE_FOLDER"

NAME_SCRIPT_DRIVE="rc-$NAME_DRIVE_RCLONE"
SCRIPT_PATH_DRIVE="/usr/local/bin/$NAME_SCRIPT_DRIVE"

NAME_SERVICE_RCLONE_DRIVE="$NAME_SCRIPT_DRIVE.service"
SERVICE_PATH_RCLONE_DRIVE="/etc/systemd/system/$NAME_SERVICE_RCLONE_DRIVE"

NAME_LOG_RCLONE_DRIVE="$NAME_SCRIPT_DRIVE.log"
PATH_LOG_RCLONE_DRIVE="/var/log/$NAME_LOG_RCLONE_DRIVE"

USER_NAME="$USER"
SYSTEMD_USER="$USER"
SYSTEMD_NAME_SERVICE="rclone-${NAME_DRIVE_RCLONE}"




# Colores de formato
FMT_RESET=$(tput sgr0)
FMT_BOLD=$(tput bold)
FMT_RED=$(tput setaf 1)
FMT_GREEN=$(tput setaf 2)
FMT_YELLOW=$(tput setaf 3)
FMT_BLUE=$(tput setaf 4)
FMT_PURPLE=$(tput setaf 5)



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

# Función para verificar si un folder existe o no en linux leyendo el primer parametro pasado, por el momento 
# esta funcion usa las variables globales ya haremos una especifica para leer todos los argumentos.
create_script_drive(){
    FILE_PATH="$1"
    if [ ! -f "$FILE_PATH" ]; then
        printf "${FMT_BLUE}Creando el script %s ya que no existe.${NC}\n" "$FILE_PATH"
        sudo bash -c "cat > $FILE_PATH" << EOF
#!/bin/bash
LOGFILE=${PATH_LOG_RCLONE_DRIVE}
/usr/bin/rclone --vfs-cache-mode writes mount "${NAME_DRIVE_RCLONE}": ~/${NAME_DRIVE_FOLDER} &> ${PATH_LOG_RCLONE_DRIVE} &
if [ \$? -eq 0 ]; then
    /usr/bin/notify-send "Microsoft OneDrive" "Microsoft OneDrive successfully mounted."
    printf "${FMT_GREEN}Mounted successfully" >> "${PATH_LOG_RCLONE_DRIVE}"
else
    printf "${FMT_RED}Failed to mount OneDrive" >> "${PATH_LOG_RCLONE_DRIVE}"
fi
EOF
        sudo chmod +x "$FILE_PATH"
    else
        printf "${FMT_BLUE}El script ya existe ${NC}\n" "$FILE_PATH"
    fi
}

create_service_drive(){
    FILE_SERVICE="$1"
    if [ ! -f "$FILE_SERVICE" ]; then
         printf "${FMT_BLUE}Creando el servicio %s ya que no existe.${NC}\n" "$FILE_SERVICE"
         sudo bash -c "cat > $FILE_SERVICE" << EOF
[Unit]
Description=Mount ${NAME_DRIVE_RCLONE} with rclone at startup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
#Environment="USER_NAME=${USER}"
ExecStart=${SCRIPT_PATH_DRIVE}
Restart=on-failure
RemainAfterExit=true
User=${USER}

[Install]
WantedBy=default.target
EOF
    else
        printf "${FMT_BLUE}El servicio ya existe ${NC}\n" "$FILE_SERVICE"
    fi
}

# Función para eliminar el script de OneDrive
delete_service_drive(){
    if [ -f "$SERVICE_PATH_RCLONE_DRIVE" ]; then
        sudo rm -f "$SERVICE_PATH_RCLONE_DRIVE"
        printf "${FMT_GREEN}Script eliminado: %s${NC}\n" "$SERVICE_PATH_RCLONE_DRIVE"
    else
        printf "${FMT_RED}El script no existe: %s${NC}\n" "$SERVICE_PATH_RCLONE_DRIVE"
    fi
}


# Función para eliminar el script de OneDrive
delete_script_drive(){
    if [ -f "$SCRIPT_PATH_DRIVE" ]; then
        sudo rm -f "$SCRIPT_PATH_DRIVE"
        printf "${FMT_GREEN}Script eliminado: %s${NC}\n" "$SCRIPT_PATH_DRIVE"
    else
        printf "${FMT_RED}El script no existe: %s${NC}\n" "$SCRIPT_PATH_DRIVE"
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
    if [ -d "$MOUNT_PATH_DRIVE" ]; then
        sudo rm -rf "$MOUNT_PATH_DRIVE"
        printf "${FMT_GREEN}Directorio eliminado: %s${NC}\n" "$MOUNT_PATH_DRIVE"
    else
        printf "${FMT_RED}El directorio no existe: %s${NC}\n" "$MOUNT_PATH_DRIVE"
    fi
}

# ==================================================================================================
# MAIN SPACE
# ==================================================================================================
main(){

    verify_folder_drive  $MOUNT_PATH_DRIVE
    create_script_drive  $SCRIPT_PATH_DRIVE
    create_service_drive $SERVICE_PATH_RCLONE_DRIVE
    # sleep 30
    # delete_script_drive
    # delete_folder_drive
    # delete_service_drive
}   

# **************************************************************************************************
# MAIN CALL
# **************************************************************************************************

#LLamada a la funcion principal (main)
main