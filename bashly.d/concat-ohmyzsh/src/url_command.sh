#!/bin/bash

# Obtener el contenido para string2
string2="$1"

# Definir los strings
string1='curl -fsSL '

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