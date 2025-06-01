#!/bin/bash

LOGFILE="/var/log/bt-connect.log"

echo "🛠️ Creando archivo de log en $LOGFILE..."

if [ ! -f "$LOGFILE" ]; then
    sudo touch "$LOGFILE"
    sudo chmod 664 "$LOGFILE"
    sudo chown root:$(whoami) "$LOGFILE"
    echo "✅ Log creado y con permisos adecuados."
else
    echo "⚠️ Ya existe el archivo de log."
fi
