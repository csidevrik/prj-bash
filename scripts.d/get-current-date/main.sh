#!/bin/bash

function Get-Current-Date() {
    # Obtiene la fecha y hora actual
    current_date=$(date '+%Y %m %d %H %M %S')
    year=$(echo $current_date | awk '{print $1}')
    month=$(echo $current_date | awk '{print $2}')
    day=$(echo $current_date | awk '{print $3}')
    hour=$(echo $current_date | awk '{print $4}')
    minute=$(echo $current_date | awk '{print $5}')
    second=$(echo $current_date | awk '{print $6}')

    # Mapa de months en español
    months=("ENE" "FEB" "MAR" "ABR" "MAY" "JUN" "JUL" "AGO" "SEP" "OCT" "NOV" "DIC")

    case $1 in
        -JustDate)
            # Formato para solo la fecha
            result=$(printf "%04d%02d%s-%02d_" $year $month ${months[$((month-1))]} $day)
            ;;
        -JustHour)
            # Formato para solo la hora
            result=$(printf "%02dh%02dm%02ds" $hour $minute $second)
            ;;
        -DayAndHour)
            # Formato para fecha y hora
            result=$(printf "%04d%02d%02d-%02dh%02dm%02ds" $year $month $day $hour $minute $second)
            ;;
        *)
            # Formato completo de fecha y hora (default)
            result=$(printf "%04d%02d%02d%02d%02d%02d" $year $month $day $hour $minute $second)
            ;;
    esac

    echo $result
}

# Ejemplos de uso:
# Para obtener solo la fecha:
Get-Current-Date -JustDate

# Para obtener solo la hora:
Get-Current-Date -JustHour

# Para obtener la fecha y hora (con mes y día):
Get-Current-Date -DayAndHour

# Para obtener la fecha completa (default):
Get-Current-Date
