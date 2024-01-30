#!/bin/bash

# Definir las variables de origen y destino
ORIGEN="/home/adminos/Music"
DESTINO="/run/media/adminos/DISK8G"
MAILDEST="carlos.sigua@gmail.com"

# Mensaje de inicio de sincronización en el archivo .log
echo "Iniciando sincronización en $(date)" >> "$DESTINO/sync.log"

# Ejecutar el comando rsync utilizando pv y redirigir la salida al archivo .log
rsync -avh "$ORIGEN/" "$DESTINO/" 2>&1 | pv -lep -s $(du -sb "$ORIGEN" | awk '{print $1}') >> "$DESTINO/sync.log"

# Mensaje de finalización de sincronización en el archivo .log
echo "Sincronización finalizada en $(date)" >> "$DESTINO/sync.log"

# Enviar un correo electrónico de confirmación
echo "La sincronización se ha completado." | mail -s "Sincronización finalizada" $MAILDEST