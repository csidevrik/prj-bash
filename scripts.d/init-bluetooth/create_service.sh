#!/bin/bash

# SERVICE_NAME="jbl-connect.service"
# SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
# SCRIPT_PATH="/usr/local/bin/connect_bt.sh"

# echo "Creando servicio systemd en $SERVICE_PATH"

# sudo tee "$SERVICE_PATH" > /dev/null <<EOF
# [Unit]
# Description=Conectar JBL Clip 4 por Bluetooth al inicio
# After=bluetooth.target
# Requires=bluetooth.service

# [Service]
# Type=oneshot
# ExecStart=$SCRIPT_PATH

# [Install]
# WantedBy=multi-user.target
# EOF

# # Recargar systemd y habilitar servicio
# sudo systemctl daemon-reexec
# sudo systemctl enable "$SERVICE_NAME"
# echo "✅ Servicio creado y habilitado. Puedes iniciarlo con: sudo systemctl start $SERVICE_NAME"

#!/bin/bash

SERVICE_NAME="jbl-connect.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
SCRIPT_PATH="/usr/local/bin/connect_bt.sh"

echo "🛠️ Creando servicio systemd en $SERVICE_PATH..."

sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Conectar JBL Clip 4 por Bluetooth al inicio
After=bluetooth.service
Wants=bluetooth.service
DefaultDependencies=no
Before=network.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reexec
sudo systemctl enable jbl-connect.service

echo "✅ Servicio creado y habilitado para el arranque."
