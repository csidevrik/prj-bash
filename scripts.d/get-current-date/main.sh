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

# Formato para diferentes opciones
case "$1" in
    --justDate)
        resultado="${day}${months[$month]}_${day}${year}"
        ;;
    --justHour)
        resultado="${hour}h${minute}m${second}s"
        ;;
    --dayAndHour)
        resultado="${months[$month]}${day}_${hour}h${minute}m${second}s"
        ;;
    *)
        # resultado="${day}${months[$month]}_${day}${year}_${hour}${minute}${second}"
        resultado="${day}${months[$monthNumber]}_${day}${monthNumber}${year}_${hour}${minute}${second}"
        ;;
esac

# Mostrar el resultado
echo "$resultado"
