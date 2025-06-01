#!/bin/bash

SCRIPT_PATH="/usr/local/bin/connect_bt.sh"
MAC="F8:5C:7E:4A:C2:54"
LOGFILE="/var/log/bt-connect.log"

echo "🛠️ Creando script $SCRIPT_PATH..."

sudo tee "$SCRIPT_PATH" > /dev/null <<EOF
#!/bin/bash

MAC="$MAC"
LOGFILE="$LOGFILE"

echo "===== \$(date) =====" >> "\$LOGFILE"
echo "Iniciando conexión Bluetooth a \$MAC" >> "\$LOGFILE"

# Esperar a que el adaptador esté activo
for i in {1..10}; do
    if bluetoothctl show | grep -q "Powered: yes"; then
        echo "Adaptador Bluetooth activo." >> "\$LOGFILE"
        break
    fi
    echo "Esperando adaptador... intento \$i" >> "\$LOGFILE"
    sleep 2
done

rfkill unblock bluetooth

bluetoothctl <<EOC >> "\$LOGFILE" 2>&1
power on
connect \$MAC
exit
EOC

if bluetoothctl info "\$MAC" | grep -q "Connected: yes"; then
    echo "✅ Conectado exitosamente a \$MAC" >> "\$LOGFILE"
else
    echo "❌ Error al conectar a \$MAC" >> "\$LOGFILE"
fi
EOF

sudo chmod +x "$SCRIPT_PATH"
echo "✅ Script creado con permisos de ejecución."
