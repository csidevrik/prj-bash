echo "# this file is located in 'src/down_command.sh'"
echo "# code for 'hidemcli down' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
hidemeService=$(systemctl list-units --type=service | grep hide.me)

echo $hidemeService