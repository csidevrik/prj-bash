#!/bin/bash

# Mapa de meses en español
declare -A months=(
    [1]="ENE" [2]="FEB" [3]="MAR" [4]="ABR"
    [5]="MAY" [6]="JUN" [7]="JUL" [8]="AGO"
    [9]="SEP" [10]="OCT" [11]="NOV" [12]="DIC"
)

# Obtener la fecha y hora actual
actualDate=$(date +'%Y-%m-%d %H:%M:%S')
day=$(date +'%d')
month=$(date +'%m')
year=$(date +'%Y')
hour=$(date +'%H')
minute=$(date +'%M')
second=$(date +'%S')

# El mes debe ser tratado como un número entero para acceder correctamente al array
# monthNumber=$((10#$month)) # El 10# fuerza la interpretación de month como base 10


# Convertir el mes a número entero para acceder correctamente al array
monthNumber=$(echo $month | sed 's/^0*//') # Elimina cualquier 0 inicial

# Formato para diferentes opciones
case "$1" in
    --justDate)
        resultado="${day}${months[$monthNumber]}_${day}${year}"
        ;;
    --justHour)
        resultado="${hour}h${minute}m${second}s"
        ;;
    --dayAndHour)
        resultado="${months[$monthNumber]}${day}_${hour}h${minute}m${second}s"
        ;;
    *)
        resultado="${day}${months[$monthNumber]}_${day}${year}_${hour}${minute}${second}"
        ;;
esac

# Mostrar el resultado
echo "$resultado"
