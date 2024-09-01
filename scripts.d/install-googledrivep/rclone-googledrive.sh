#!/bin/bash
LOGFILE=/var/log/rclonegoogledrivep.log
/usr/bin/rclone --vfs-cache-mode writes mount "GoogleDriveP": ~/GoogleDriveP &> $LOGFILE &
if [ $? -eq 0 ]; then
	/usr/bin/notify-send "Google Drive" "Google Drive successfully mounted."
	echo "Mounted succesfully" >> "$LOGFILE"
else
	echo "Failed to mount GoogleDrive" >> "$LOGFILE"
fi