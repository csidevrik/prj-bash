# Mount Google Drive Personal on linux

## Install rclone

First we need to known a way to get rclone configured completelly
and ready to use.

On Fedora

```
    sudo dnf install rclone
```

On Ubuntu

```
    sudo apt install rclone
```

Una vez esta instalado ahora debe estar configurado

Para eso seguiremos los siguientes pasos.

## Configure rclone

Revisa los siguientes tutoriales de como enlazar o montar googledrive usando rclone, analizalos y adaptalos para tu necesidad.

> **[Guia oficial de rclone](https://rclone.org/drive/)**
>
> [Tutorial mas explicado](https://www.jaumeferre.net/single_post.php?post-alias=sincronizar-google-drive-con-rclone)

## Create a Directory for OneDrive

We need to create a root directory for mount GoogleDriveP

```
mkdir ~/GoogleDriveP
```

The last command is using a user.

## Create a log file for the service

Create a log file named as rc-GoogleDriveP.log on directory /var/log and this file is owned by the user actual.

sudo touch /var/log/rc-GoogleDriveP.log

sudo chown user:user /var/log/rc-GoogleDriveP.log

**Note:** Tomar muy en cuenta que user es el usuario actual de la terminal y ***debes de reemplazarlo por tu usuario.***

## Setup Script Bash online

We write a code to mount a OneDrive volumen

The code was written using bash and is:

```
#!/bin/bash
=/var/log/rcloneonedrivep.log
/usr/bin/rclone --vfs-cache-mode writes mount "OneDriveP": ~/OneDriveP &> /var/log/rcloneonedrivep.log &
if [ $? -eq 0 ]; then
	/usr/bin/notify-send "Microsoft OneDrive" "Microsoft OneDrive successfully mounted."
	echo "Mounted succesfully" >> "$LOGFILE"
else
	echo "Failed to mount OneDrive" >> "$LOGFILE"
fi
```

Since July 2024 i used to use this script upload on the path /usr/local/bin in this case we use the name rclone-onedriveP and give it execute permision.

Then I thought about parameterizing

Add text for /var/log/rcloneonedrivep.log

```
#!/bin/bashParámetros configurablesLOGFILE="/var/log/rcloneonedrivep.log"
MOUNT_POINT="$HOME/OneDriveP"
REMOTE_NAME="OneDriveP"Montar OneDrive usando rclone/usr/bin/rclone --vfs-cache-mode writes mount "REMOTE_NAME": "REMOTENAME":"MOUNT_POINT" &> "$LOGFILE" &Verificar si el montaje fue exitosoif [ $? -eq 0 ]; then
    /usr/bin/notify-send "Microsoft OneDrive" "Microsoft OneDrive successfully mounted."
    echo "Mounted successfully" >> "$LOGFILE"
else
    echo "Failed to mount OneDrive" >> "$LOGFILE"
fi
```

The parametrization will be util on the next headings.

## Setup Service for Systemd

Then i think why do not to do it runs automatically like at windows systems but only once because execute every terminal session is so hard and inutil.

Edit file /etc/systemd/system/rclone-onedriveps.service

```
[Unit]
Description=Mount OneDrive with rclone at startup
After=network-online.target
Wants=network-online.target[Service]
Type=oneshot
ExecStart=/usr/local/bin/rclone-onedriveP
Restart=on-failure
RemainAfterExit=true
User=adminos[Install]
WantedBy=default.target
```

End tutorial
