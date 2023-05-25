#!/bin/bash

# Variables
moodle_version="4.2"  # Versión de Moodle que deseas instalar
moodle_directory="/var/www/html/moodle"  # Directorio de instalación de Moodle
moodle_data_directory="/var/www/moodledata"  # Directorio de datos de Moodle
db_name="moodle"  # Nombre de la base de datos
db_user="moodleuser"  # Usuario de la base de datos
db_pass="s3r4ph8.#"  # Contraseña de la base de datos
db_host="localhost"  # Host de la base de datos

# Actualizar paquetes existentes
sudo apt update

# Instalar dependencias requeridas
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-gd php-xml php-curl php-zip php-intl php-mbstring php-xmlrpc unzip

# Descargar Moodle
# wget "https://download.moodle.org//stable${moodle_version//./}/moodle-${moodle_version}.zip" -P /tmp
wget "https://download.moodle.org/download.php/stable402/${moodle_version}.zip" -P /tmp
# wget "https://download.moodle.org/download.php/stable401/moodle-4.1.zip" -P /tmp
sudo unzip "/tmp/moodle-${moodle_version}.zip" -d "${moodle_directory}"

# Configurar permisos
sudo chown -R www-data:www-data "${moodle_directory}"
sudo chmod -R 755 "${moodle_directory}"
sudo mkdir -p "${moodle_data_directory}"
sudo chown -R www-data:www-data "${moodle_data_directory}"
sudo chmod -R 755 "${moodle_data_directory}"

# Crear la base de datos y el usuario
sudo mysql -e "CREATE DATABASE ${db_name} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER '${db_user}'@'${db_host}' IDENTIFIED BY '${db_pass}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'${db_host}';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configurar Apache
sudo cp "${moodle_directory}/config.php" "${moodle_directory}/config.php.backup"
sudo sed -i "s/usernamehere/${db_user}/g; s/passwordhere/${db_pass}/g; s/example.com/${db_host}/g" "${moodle_directory}/config.php"
sudo cp "${moodle_directory}/config-dist.php" "${moodle_directory}/config.php"
sudo chown www-data "${moodle_directory}/config.php"

# Reiniciar servicios
sudo systemctl restart apache2
sudo systemctl restart mysql

echo "La instalación de Moodle se ha completado correctamente."
