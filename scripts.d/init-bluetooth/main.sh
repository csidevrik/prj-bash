#!/bin/bash

MAC="F8:5C:7E:4A:C2:54"

# Esperar hasta que el adaptador esté encendido
for i in {1..10}; do
    if bluetoothctl show | grep -q "Powered: yes"; then
        break
    fi
    echo "Esperando que el adaptador Bluetooth esté listo..."
    sleep 2
done

rfkill unblock bluetooth

bluetoothctl <<EOF
power on
connect $MAC
exit
EOF