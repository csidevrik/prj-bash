#!/bin/zsh
# Global variables
# ========================================================================
typeset -A directory_names

# Directorio base
BASEDIR="/home/adminos/dev/remote"
# Obtener la lista de carpetas existentes
EXISTING_FOLDERS=($BASEDIR/*(/:t))
oldprefix="prj-"
newprefix="WD"



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

# -----------------------------------------------------------------------------------------------
# Función principal
# -----------------------------------------------------------------------------------------------
main() {
    # Mensaje de inicio en color púrpura
    print_white "¡Bienvenido al script de configuración!"
    
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

    # Resto del código...
}

# Llamar a la función principal
main