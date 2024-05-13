#!/bin/sh

# Descargar el script remoto
wget https://raw.githubusercontent.com/csidevrik/prj-bash/main/scripts.d/test/lib/colores.sh -O /tmp/colores.sh

# Verificar si la descarga fue exitosa
if [ $? -eq 0 ]; then
    # Incluir el script descargado
    source /tmp/colores.sh
    # Ahora puedes usar las funciones del script 'colores.sh'
    print_purple "solo es purpura"
    print_white "subjetivo"

    # Limpieza: eliminar el script descargado después de usarlo
    rm /tmp/colores.sh
else
    # Si la descarga falla, mostrar un mensaje de error
    echo "Error: No se pudo descargar el script 'colores.sh' desde GitHub."
fi




