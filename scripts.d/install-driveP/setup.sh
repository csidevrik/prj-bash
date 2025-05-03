#!/bin/bash

# ==================================================================================================
# VARIABLE SPACE
# ==================================================================================================

DRIVE_REMOTE_NAME="MyDriveRemote"        # Nombre remoto de rclone (ej: "gdrive", "onedrive", "dropbox")
DRIVE_FOLDER_NAME="MyDriveFolder"         # Carpeta de montaje local
MOUNT_PATH_DRIVE="$HOME/$DRIVE_FOLDER_NAME"

SCRIPT_NAME="rc-${DRIVE_REMOTE_NAME}"
SCRIPT_PATH="/usr/local/bin/$SCRIPT_NAME"

SERVICE_NAME="${SCRIPT_NAME}.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

LOG_NAME="${SCRIPT_NAME}.log"
LOG_PATH="/var/log/$LOG_NAME"

USER_NAME="$USER"

# Colores
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

print_success() {
  printf '\n%s%s%s\n' "${FMT_GREEN}${FMT_BOLD}" "¡Instalación exitosa!" "${FMT_RESET}"
}

create_script_drive() {
    FILE_PATH="$1"
    if [ ! -f "$FILE_PATH" ]; then
        printf "${FMT_BLUE}Creando el script %s ya que no existe.${FMT_RESET}\n" "$FILE_PATH"
        sudo bash -c "cat > $FILE_PATH" << EOF
#!/bin/bash
LOGFILE=${LOG_PATH}
/usr/bin/rclone --vfs-cache-mode writes mount "${DRIVE_REMOTE_NAME}": ~/${DRIVE_FOLDER_NAME} &> ${LOG_PATH} &
if [ \$? -eq 0 ]; then
    /usr/bin/notify-send "${DRIVE_REMOTE_NAME}" "${DRIVE_REMOTE_NAME} mounted successfully."
    printf "${FMT_GREEN}Mounted successfully\n" >> "${LOG_PATH}"
else
    printf "${FMT_RED}Failed to mount ${DRIVE_REMOTE_NAME}\n" >> "${LOG_PATH}"
fi
EOF
        sudo chmod +x "$FILE_PATH"
    else
        printf "${FMT_YELLOW}El script ya existe: %s${FMT_RESET}\n" "$FILE_PATH"
    fi
}

create_service_drive() {
    FILE_SERVICE="$1"
    if [ ! -f "$FILE_SERVICE" ]; then
        printf "${FMT_BLUE}Creando el servicio %s.${FMT_RESET}\n" "$FILE_SERVICE"
        sudo bash -c "cat > $FILE_SERVICE" << EOF
[Unit]
Description=Mount ${DRIVE_REMOTE_NAME} with rclone at startup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${SCRIPT_PATH}
Restart=on-failure
RemainAfterExit=true
User=${USER_NAME}

[Install]
WantedBy=default.target
EOF
    else
        printf "${FMT_YELLOW}El servicio ya existe: %s${FMT_RESET}\n" "$FILE_SERVICE"
    fi
}

delete_service_drive() {
    if [ -f "$SERVICE_PATH" ]; then
        sudo rm -f "$SERVICE_PATH"
        printf "${FMT_GREEN}Servicio eliminado: %s${FMT_RESET}\n" "$SERVICE_PATH"
    else
        printf "${FMT_RED}El servicio no existe: %s${FMT_RESET}\n" "$SERVICE_PATH"
    fi
}

delete_script_drive() {
    if [ -f "$SCRIPT_PATH" ]; then
        sudo rm -f "$SCRIPT_PATH"
        printf "${FMT_GREEN}Script eliminado: %s${FMT_RESET}\n" "$SCRIPT_PATH"
    else
        printf "${FMT_RED}El script no existe: %s${FMT_RESET}\n" "$SCRIPT_PATH"
    fi
}

verify_folder_drive() {
    DIR_PATH="$1"
    if [ -d "$DIR_PATH" ]; then
        printf "${FMT_BLUE}El directorio ya existe: %s${FMT_RESET}\n" "$DIR_PATH"
    else
        printf "${FMT_YELLOW}El directorio %s no existe.${FMT_RESET}\n" "$DIR_PATH"
        printf "${FMT_YELLOW}¿Deseas crearlo? (Y/N): ${FMT_RESET}"
        read -r respuesta
        if [[ "$respuesta" =~ ^[Yy]$ ]]; then
            mkdir -p "$DIR_PATH"
            printf "${FMT_GREEN}Directorio creado: %s${FMT_RESET}\n" "$DIR_PATH"
        else
            printf "${FMT_RED}No se creó el directorio: %s${FMT_RESET}\n" "$DIR_PATH"
        fi
    fi
}

delete_folder_drive() {
    if [ -d "$MOUNT_PATH_DRIVE" ]; then
        sudo rm -rf "$MOUNT_PATH_DRIVE"
        printf "${FMT_GREEN}Directorio eliminado: %s${FMT_RESET}\n" "$MOUNT_PATH_DRIVE"
    else
        printf "${FMT_RED}El directorio no existe: %s${FMT_RESET}\n" "$MOUNT_PATH_DRIVE"
    fi
}

# ==================================================================================================
# MAIN SPACE
# ==================================================================================================

main() {
    verify_folder_drive "$MOUNT_PATH_DRIVE"
    create_script_drive "$SCRIPT_PATH"
    create_service_drive "$SERVICE_PATH"
    # sleep 30
    # delete_script_drive
    # delete_folder_drive
    # delete_service_drive
}   

# **************************************************************************************************
# MAIN CALL
# **************************************************************************************************

main
