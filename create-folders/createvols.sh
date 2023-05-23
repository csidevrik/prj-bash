# Directorio base
directorio_base="/home/$USER"

# Crear directorios
directorios=(
  "mariadb/data"
  "mariadb/logs"
  "mariadb1/data"
  "mariadb1/logs"
  "mongodb/data"
  "mongodb/logs"
  "postgres/data"
  "postgres/logs"
)

# Iterar sobre la lista de directorios y crearlos
for directorio in "${directorios[@]}"; do
  ruta_directorio="$directorio_base/$directorio"
  
  # Verificar si el directorio ya existe
  if [ -d "$ruta_directorio" ]; then
    echo "El directorio $ruta_directorio ya existe. Omite la creación."
  else
    mkdir -p "$ruta_directorio"
    echo "Se ha creado el directorio $ruta_directorio."
  fi
done