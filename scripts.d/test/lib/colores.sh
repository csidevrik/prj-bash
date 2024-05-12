# -- FUNCIONES DE COLORES ---
print_color() {
  local message=$1
  local color=$2
  echo -e "\e[${color}m${message}\e[0m"
}
# Función para imprimir un mensaje en color púrpura
print_purple() {
  local message=$1
  echo -e "\e[35m$message\e[0m"
}
# Función para imprimir un mensaje en color yellow
print_yellow() {
  local message=$1
  echo -e "\e[33m$message\e[0m"
}
# Función para imprimir un mensaje en color azul
print_blue() {
  local message=$1
  echo -e "\e[34m$message\e[0m"
}
# Función para imprimir un mensaje en color blanco
print_white() {
  local message=$1
  echo -e "\e[37m$message\e[0m"
}