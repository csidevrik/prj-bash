#!/bin/bash
LOGFILE=/var/log/rcloneonedrivep.log
/usr/bin/rclone --vfs-cache-mode writes mount "OneDriveP": ~/OneDriveP &> /var/log/rcloneonedrivep.log &
if [ $? -eq 0 ]; then
	/usr/bin/notify-send "Microsoft OneDrive" "Microsoft OneDrive successfully mounted."
	echo "Mounted succesfully" >> "$LOGFILE"
else
	echo "Failed to mount OneDrive" >> "$LOGFILE"
fi