SCRIPTS USING BASH, ZSH OR SH
------------------------------------------------

In this repo we share somethings script writen for automatice something tasks for linux development or for infrastructure

## BASHLY DIRECTORY
En esta carpeta tratamos de mejorar algunos scripts para nuestras necesidades generales dentro de la creacion de maquinas virtuales, algunas tareas basicas como crear directorios, concatenar y formar cadenas de comandos, crear otros scripts pero utilizando bashly un framework creado en ruby para estos fines 
- [Bashly framework](https://bashly.dannyb.co/)

Para visitar lo que estoy construyendo tienes el siguiente link
- [bashly directory](https://github.com/carlossiguam/prj-bash/tree/main/bashly.d)

## SCRIPTS DIRECTORY
On this directory we have scripts low complexity, only build with bash or sh enviroment, obviously we will improve it over time.

For visit that i building you have next link
- [Script directory](https://github.com/carlossiguam/prj-bash/tree/main/scripts.d)


### Install utils
De momento he creado un script que permite la instalacion de algunas librerias utiles tanto en fedora como en ubuntu. 

Para utilizar este script inserta lo siguiente en la terminal.

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/carlossiguam/prj-bash/main/scripts.d/install-utils/install.sh)"
```

Tambien adjunto el script para ohmyzsh, es que sino tengo que estar ingresando al sitio de oh my zsh

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
