#!/bin/sh

# Verificar si ya está instalado Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh ya está instalado en el sistema."
  exit 0
fi

# Instalar Oh My Zsh sin solicitar contraseña
echo "Iniciando la instalación de Oh My Zsh..."
sudo -n sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# # Cambiar la shell predeterminada a Zsh
# echo "Cambiando la shell predeterminada a Zsh..."
# chsh -s "$(which zsh)"

# # Configurar Zsh como la shell actual
# export SHELL=$(which zsh)
# exec zsh -l