#!/bin/sh

# ==================================================================================================
# VARIABLE SPACE
# ==================================================================================================

NAME_DRIVE_RCLONE=GoogleDriveP
NAME_DRIVE_FOLDER=GoogleDriveP
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

create_script_drive(){
    FILE_PATH="$1"
    if [ ! -f "$FILE_PATH" ]; then
        printf "${FMT_BLUE}Creando el script %s ya que no existe.${FMT_RESET}\n" "$FILE_PATH"
        sudo bash -c "cat > $FILE_PATH" << EOF
#!/bin/bash
LOGFILE=${PATH_LOG_RCLONE_DRIVE}
/usr/bin/rclone --vfs-cache-mode writes mount "${NAME_DRIVE_RCLONE}": ~/${NAME_DRIVE_FOLDER} &> ${PATH_LOG_RCLONE_DRIVE} &
if [ \$? -eq 0 ]; then
    /usr/bin/notify-send "Google Drive" "Google Drive successfully mounted."
    printf "${FMT_GREEN}Mounted successfully" >> "${PATH_LOG_RCLONE_DRIVE}"
else
    printf "${FMT_RED}Failed to mount Google Drive" >> "${PATH_LOG_RCLONE_DRIVE}"
fi
EOF
        sudo chmod +x "$FILE_PATH"
    else
        printf "${FMT_BLUE}El script ya existe: %s${FMT_RESET}\n" "$FILE_PATH"
    fi
}

create_service_drive(){
    FILE_SERVICE="$1"
    if [ ! -f "$FILE_SERVICE" ]; then
        printf "${FMT_BLUE}Creando el servicio %s ya que no existe.${FMT_RESET}\n" "$FILE_SERVICE"
        sudo bash -c "cat > $FILE_SERVICE" << EOF
[Unit]
Description=Mount ${NAME_DRIVE_RCLONE} with rclone at startup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${SCRIPT_PATH_DRIVE}
Restart=on-failure
RemainAfterExit=true
User=${USER}

[Install]
WantedBy=default.target
EOF
    else
        printf "${FMT_BLUE}El servicio ya existe: %s${FMT_RESET}\n" "$FILE_SERVICE"
    fi
}

create_log_drive(){
    if [ ! -f "$PATH_LOG_RCLONE_DRIVE" ]; then
        sudo touch "$PATH_LOG_RCLONE_DRIVE"
        sudo chown "$USER_NAME":"$USER_NAME" "$PATH_LOG_RCLONE_DRIVE"
        sudo chmod 664 "$PATH_LOG_RCLONE_DRIVE"
        printf "${FMT_GREEN}Archivo de log creado: %s${FMT_RESET}\n" "$PATH_LOG_RCLONE_DRIVE"
    else
        printf "${FMT_BLUE}El archivo de log ya existe: %s${FMT_RESET}\n" "$PATH_LOG_RCLONE_DRIVE"
    fi
}

unmount_drive(){
    if pgrep -f "rclone.*${NAME_DRIVE_RCLONE}" > /dev/null; then
        pkill -f "rclone.*${NAME_DRIVE_RCLONE}"
        sleep 1
        printf "${FMT_YELLOW}Proceso rclone terminado.${FMT_RESET}\n"
    fi

    if mountpoint -q "$MOUNT_PATH_DRIVE"; then
        fusermount -u "$MOUNT_PATH_DRIVE"
        if [ $? -eq 0 ]; then
            printf "${FMT_GREEN}Drive desmontado: %s${FMT_RESET}\n" "$MOUNT_PATH_DRIVE"
        else
            printf "${FMT_RED}Error al desmontar. Intentando forzar...${FMT_RESET}\n"
            fusermount -uz "$MOUNT_PATH_DRIVE"
        fi
    else
        printf "${FMT_YELLOW}El drive no está montado: %s${FMT_RESET}\n" "$MOUNT_PATH_DRIVE"
    fi
}

delete_service_drive(){
    if [ -f "$SERVICE_PATH_RCLONE_DRIVE" ]; then
        sudo rm -f "$SERVICE_PATH_RCLONE_DRIVE"
        printf "${FMT_GREEN}Servicio eliminado: %s${FMT_RESET}\n" "$SERVICE_PATH_RCLONE_DRIVE"
    else
        printf "${FMT_RED}El servicio no existe: %s${FMT_RESET}\n" "$SERVICE_PATH_RCLONE_DRIVE"
    fi
}

delete_script_drive(){
    if [ -f "$SCRIPT_PATH_DRIVE" ]; then
        sudo rm -f "$SCRIPT_PATH_DRIVE"
        printf "${FMT_GREEN}Script eliminado: %s${FMT_RESET}\n" "$SCRIPT_PATH_DRIVE"
    else
        printf "${FMT_RED}El script no existe: %s${FMT_RESET}\n" "$SCRIPT_PATH_DRIVE"
    fi
}

delete_log_drive(){
    if [ -f "$PATH_LOG_RCLONE_DRIVE" ]; then
        sudo rm -f "$PATH_LOG_RCLONE_DRIVE"
        printf "${FMT_GREEN}Log eliminado: %s${FMT_RESET}\n" "$PATH_LOG_RCLONE_DRIVE"
    else
        printf "${FMT_RED}El log no existe: %s${FMT_RESET}\n" "$PATH_LOG_RCLONE_DRIVE"
    fi
}

verify_folder_drive(){
    DIR_PATH="$1"
    if [ -d "$DIR_PATH" ]; then
        printf "${FMT_BLUE}El directorio ya existe: %s${FMT_RESET}\n" "$DIR_PATH"
    else
        printf "${FMT_RED}El directorio %s no existe.${FMT_RESET}\n" "$DIR_PATH"
        printf "${FMT_YELLOW}¿Deseas crearlo? (Y/N): ${FMT_RESET}"
        read -r respuesta
        if [ "$respuesta" = "y" ] || [ "$respuesta" = "Y" ]; then
            mkdir -p "$DIR_PATH"
            printf "${FMT_GREEN}El directorio %s ha sido creado.${FMT_RESET}\n" "$DIR_PATH"
        else
            printf "${FMT_RED}El directorio %s no se ha creado.${FMT_RESET}\n" "$DIR_PATH"
        fi
    fi
}

delete_folder_drive(){
    unmount_drive
    if [ -d "$MOUNT_PATH_DRIVE" ]; then
        sudo rm -rf "$MOUNT_PATH_DRIVE"
        printf "${FMT_GREEN}Directorio eliminado: %s${FMT_RESET}\n" "$MOUNT_PATH_DRIVE"
    else
        printf "${FMT_RED}El directorio no existe: %s${FMT_RESET}\n" "$MOUNT_PATH_DRIVE"
    fi
}

# ==================================================================================================
# MENU SPACE
# ==================================================================================================

print_header(){
    clear
    printf "\n"
    printf "%s╔══════════════════════════════════════════════╗%s\n" "${FMT_BLUE}${FMT_BOLD}" "${FMT_RESET}"
    printf "%s║       rclone Google Drive Manager v1.0       ║%s\n" "${FMT_BLUE}${FMT_BOLD}" "${FMT_RESET}"
    printf "%s║       Drive: %-32s║%s\n" "${FMT_BLUE}${FMT_BOLD}" "${NAME_DRIVE_RCLONE}" "${FMT_RESET}"
    printf "%s╚══════════════════════════════════════════════╝%s\n" "${FMT_BLUE}${FMT_BOLD}" "${FMT_RESET}"
    printf "\n"
}

print_status(){
    local folder_status script_status service_status log_status mount_status

    [ -d "$MOUNT_PATH_DRIVE" ]          && folder_status="${FMT_GREEN}✔ existe${FMT_RESET}"   || folder_status="${FMT_RED}✘ no existe${FMT_RESET}"
    [ -f "$SCRIPT_PATH_DRIVE" ]         && script_status="${FMT_GREEN}✔ existe${FMT_RESET}"   || script_status="${FMT_RED}✘ no existe${FMT_RESET}"
    [ -f "$SERVICE_PATH_RCLONE_DRIVE" ] && service_status="${FMT_GREEN}✔ existe${FMT_RESET}"  || service_status="${FMT_RED}✘ no existe${FMT_RESET}"
    [ -f "$PATH_LOG_RCLONE_DRIVE" ]     && log_status="${FMT_GREEN}✔ existe${FMT_RESET}"      || log_status="${FMT_RED}✘ no existe${FMT_RESET}"
    mountpoint -q "$MOUNT_PATH_DRIVE"   && mount_status="${FMT_GREEN}✔ montado${FMT_RESET}"   || mount_status="${FMT_RED}✘ no montado${FMT_RESET}"

    printf "%s  Estado actual:%s\n" "${FMT_YELLOW}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %-20s %b\n" "Carpeta montaje:"  "$folder_status"
    printf "  %-20s %b\n" "Drive montado:"    "$mount_status"
    printf "  %-20s %b\n" "Script:"           "$script_status"
    printf "  %-20s %b\n" "Servicio:"         "$service_status"
    printf "  %-20s %b\n" "Log:"              "$log_status"
    printf "\n"
}

print_menu(){
    printf "%s  ── INSTALAR ──────────────────────────────%s\n" "${FMT_PURPLE}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[1]%s Crear carpeta de montaje\n"   "${FMT_GREEN}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[2]%s Crear log\n"                  "${FMT_GREEN}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[3]%s Crear script\n"               "${FMT_GREEN}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[4]%s Crear servicio\n"             "${FMT_GREEN}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[5]%s Instalar todo\n"              "${FMT_GREEN}${FMT_BOLD}" "${FMT_RESET}"
    printf "\n"
    printf "%s  ── ELIMINAR ──────────────────────────────%s\n" "${FMT_PURPLE}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[6]%s Eliminar carpeta de montaje\n" "${FMT_RED}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[7]%s Eliminar log\n"               "${FMT_RED}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[8]%s Eliminar script\n"            "${FMT_RED}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[9]%s Eliminar servicio\n"          "${FMT_RED}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[10]%s Eliminar todo\n"             "${FMT_RED}${FMT_BOLD}" "${FMT_RESET}"
    printf "\n"
    printf "%s  ── OTROS ─────────────────────────────────%s\n" "${FMT_PURPLE}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[11]%s Ver log en vivo\n"           "${FMT_YELLOW}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[12]%s Desmontar drive\n"           "${FMT_YELLOW}${FMT_BOLD}" "${FMT_RESET}"
    printf "  %s[0]%s  Salir\n"                     "${FMT_BOLD}" "${FMT_RESET}"
    printf "\n"
    printf "%s  Elige una opción: %s" "${FMT_YELLOW}${FMT_BOLD}" "${FMT_RESET}"
}

menu(){
    while true; do
        print_header
        print_status
        print_menu
        read -r opcion
        printf "\n"
        case "$opcion" in
            1)  verify_folder_drive "$MOUNT_PATH_DRIVE" ;;
            2)  create_log_drive ;;
            3)  create_script_drive "$SCRIPT_PATH_DRIVE" ;;
            4)  create_service_drive "$SERVICE_PATH_RCLONE_DRIVE" ;;
            5)  verify_folder_drive "$MOUNT_PATH_DRIVE"
                create_log_drive
                create_script_drive "$SCRIPT_PATH_DRIVE"
                create_service_drive "$SERVICE_PATH_RCLONE_DRIVE" ;;
            6)  delete_folder_drive ;;
            7)  delete_log_drive ;;
            8)  delete_script_drive ;;
            9)  delete_service_drive ;;
            10) delete_folder_drive
                delete_log_drive
                delete_script_drive
                delete_service_drive ;;
            11) tail -f "$PATH_LOG_RCLONE_DRIVE" ;;
            12) unmount_drive ;;
            0)  printf "%sSaliendo...%s\n\n" "${FMT_YELLOW}" "${FMT_RESET}"; break ;;
            *)  printf "%sOpción inválida.%s\n" "${FMT_RED}" "${FMT_RESET}" ;;
        esac
        printf "\n%s  Presiona Enter para continuar...%s" "${FMT_YELLOW}" "${FMT_RESET}"
        read -r
    done
}

# **************************************************************************************************
# MAIN CALL
# **************************************************************************************************
main(){
    menu
}
main
