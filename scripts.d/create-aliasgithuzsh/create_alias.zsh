#!/bin/zsh
# Global variables
# ========================================================================
typeset -A directory_names

# Folder repo
GITFOLDER="github"
# Directorio base
BASEDIR="/home/adminos/dev/$GITFOLDER"
# Obtener la lista de carpetas existentes
EXISTING_FOLDERS=($BASEDIR/*(/:t))

# Establecer los prefijos nuevos y los actuales
oldprefix="prj-"
newprefix="WD"

# Establecer los comentarios de inicio y fin
comment_start="# Sta Alias for $GITFOLDER repos"
comment_end="# End Alias for $GITFOLDER repos"



# Functions utils
# ========================================================================
# Función para imprimir un mensaje en color púrpura
print_purple() {
  local message=$1
  echo -e "\e[35m$message\e[0m"
}
print_color() {
  local message=$1
  local color=$2
  echo -e "\e[${color}m${message}\e[0m"
}
# Función para imprimir un mensaje en color yellow
print_yellow() {
  local message=$1
  echo -e "\e[33m$message\e[0m"
}
# Función para imprimir un mensaje en color azul
print_blue() {
  local message=$1
  echo -e "\e[34m$message\e[0m"
}
# Función para imprimir un mensaje en color blanco
print_white() {
  local message=$1
  echo -e "\e[37m$message\e[0m"
}
# Función para limpiar el nombre de la carpeta
del_prefix() {
  local folder_name=$1
  local prefix=$2
  local clean_name=${folder_name#$prefix}
  echo "$clean_name"
}
# Función para agregar un prefijo al nombre
add_prefix() {
  local name=$1
  local prefix=$2
  local result="${prefix}${name}"
#   local result="${prefix}${name#"$prefix"}"
  echo "$result"
}

# Función para agregar un comentario al archivo ~/.zshrc
add_comment() {
    local comment=$1
    echo "$comment" >> ~/.zshrc
}

# Función para verificar y borrar las líneas entre los comentarios de inicio y fin
check_and_clear_lines() {
    local start_line
    local end_line
    # Verificar si existen los comentarios de inicio y fin
    if grep -q "^$comment_start" ~/.zshrc && grep -q "^$comment_end" ~/.zshrc; then
        print_white "ha encontrado comentario inicial y final"
        # Obtener el número de línea del comentario de inicio
        start_line=$(grep -n "^$comment_start" ~/.zshrc | cut -d ":" -f 1)

        # Obtener el número de línea del comentario de fin
        end_line=$(grep -n "^$comment_end" ~/.zshrc | cut -d ":" -f 1)

        # Borrar las líneas entre los comentarios de inicio y fin
        sed -i "${start_line},${end_line}d" ~/.zshrc
    fi
}


# -----------------------------------------------------------------------------------------------
# Función principal
# -----------------------------------------------------------------------------------------------
main() {

    # Mensaje de inicio en color púrpura
    print_yellow "¡Bienvenido al script de configuración!"

    # Verificar la existencia de las lineas de inicio y final 
    check_and_clear_lines

    add_comment "$comment_start"

    for folder in $EXISTING_FOLDERS; do
        # Limpiar el nombre del directoro y obtener el nombre
        clean_name=$(del_prefix "$folder" "$oldprefix")

        # Adding el prefijo para el nombre variable del directorio para zsh
        directory_name=$(add_prefix "$clean_name" "$newprefix")

        # Construir la ruta completa del directorio
        directory_path="$BASEDIR/$folder"

        # Almacenar el nombre del directorio en el arreglo asociativo
        directory_names[$directory_name]=$directory_path

        # Mostrar en prompt el resultado de la primera linea de configuracion del directorio
        echo "${directory_name}=\"$directory_path\"" >> ~/.zshrc
        # Mostrar en prompt el resultado de crear el alias para usar ese directorio
        echo "alias open.${directory_name}=\"cd \${${directory_name}}\"" >> ~/.zshrc
    done

    add_comment "$comment_end"


    # Resto del código...
}

# Llamar a la función principal
main