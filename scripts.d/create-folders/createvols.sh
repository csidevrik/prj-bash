#!/bin/sh

# Obtener el nombre de usuario actual
usuario=$(whoami)

# Directorio base
directorio_base="/home/$usuario"

# Leer nombres de directorios desde el archivo
archivo_directorios="directories.txt"
directorios=$(cat "$archivo_directorios")
echo $directorios

# Iterar sobre la lista de directorios y crearlos
for directorio in $directorios; do
  ruta_directorio="$directorio_base/$directorio"
  # Verificar si el directorio ya existe
  if [ -d "$ruta_directorio" ]; then
    echo "El directorio $ruta_directorio ya existe. Omite la creación."
  else
    mkdir -p "$ruta_directorio"
    echo "Se ha creado el directorio $ruta_directorio ."
  fi
done
  # ruta_directorio="$directorio_base/${directorio//\//\/}"
