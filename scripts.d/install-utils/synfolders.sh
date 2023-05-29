#!/bin/zsh

# Función para imprimir un mensaje en color amarillo
print_yellow() {
  local message=$1
  echo -e "\e[33m$message\e[0m"
}

# Función para imprimir un mensaje en color azul
print_blue() {
  local message=$1
  echo -e "\e[34m$message\e[0m"
}

# Función para generar el nombre de la variable
generate_variable_name() {
  local folder_name=$1
  local prefix="prj-"
  local variable_name="${folder_name##$prefix}"
  variable_name=${variable_name^^}
  echo "$variable_name"
}

# Función principal
main() {
  # Mensaje de bienvenida
  print_yellow "¡Bienvenido al script de configuración!"

  # Directorio base
  BASEDIR="/home/adminos/dev/remote"

  # Obtener la lista de carpetas existentes
  EXISTING_FOLDERS=($BASEDIR/*(/:t))

  # Guardar la lista de nombres de variables
  VARIABLE_NAMES=()

#   # Recorrer la lista de directorios existentes
#   for folder in $EXISTING_FOLDERS; do
#     # Generar el nombre de la variable
#     variable_name=$(generate_variable_name "$folder")

#     # Imprimir el resultado
#     print_blue "Resultado de la carpeta '$folder': $variable_name"

#     # Agregar el nombre de la variable a la lista
#     VARIABLE_NAMES+=("$variable_name")
#   done

  # Imprimir la lista de directorios
  print_blue "Lista de nombres de variables:"
  for directory in "${EXISTING_FOLDERS[@]}"; do
    echo "- $directory"
  done

#   probando la funcion para eliminar los nombres
    # nombrevariable=$(generate_variable_name $EXISTING_FOLDERS[0])
    print_yellow "Es es la variable: $nombrevariable"
}

# Llamar a la función principal
main
