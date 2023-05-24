#!/bin/bash

# Verificar si se proporcionó el argumento para string2
if [ $# -ne 1 ]; then
  echo -e "\033[48;5;9m\033[38;5;7mERROR:\033[0m Debes proporcionar el contenido para string2 como argumento al ejecutar el script."
  echo "Uso: ./script.sh <string2>"
  exit 1
fi

# Obtener el contenido de string2 del argumento
string2="$1"
# Definir los strings
string1='curl -fsSL '
# string2='https://bitbucket.org/carlitoxs09/prj-bash/raw/ee4a5e9048764b61ecb442d484edea61a9bc55b8/scripts.d/create-folders/createvols.sh'

# Concatenar los strings
result="$string1$string2"

# Encerrar el string resultante entre paréntesis
result="($result)"

# Añadir el símbolo $
result="$"$result

# Encerrar el string resultante entre comillas dobles
result="\"$result\""

# Añadir "sh -c " al principio del string resultante
result="sh -c $result"

# Mostrar el string en el prompt con diferentes colores
echo -e "\033[38;5;208mINFO:\033[0m \033[38;5;6m$result"

# Guardar el string en un archivo externo llamado output.txt
echo "$result" > output.txt

echo -e "\033[38;5;7mEl script ha finalizado."