SCRIPTS USING BASH, ZSH OR SH
------------------------------------------------

In this repo we share somethings script writen for automatice something tasks for linux development or for infrastructure

## BASHLY DIRECTORY
En esta carpeta tratamos de mejorar algunos scripts para nuestras necesidades generales dentro de la creacion de maquinas virtuales, algunas tareas basicas como crear directorios, concatenar y formar cadenas de comandos, crear otros scripts pero utilizando bashly un framework creado en ruby para estos fines 
- [Bashly framework](https://bashly.dannyb.co/)

Para visitar lo que estoy construyendo tienes el siguiente link
- [bashly directory](https://github.com/csidevrik/prj-bash/tree/main/bashly.d)

## SCRIPTS DIRECTORY
On this directory we have scripts low complexity, only build with bash or sh enviroment, obviously we will improve it over time.

For visit that i building you have next link
- [Script directory](https://github.com/csidevrik/prj-bash/tree/main/scripts.d)


### Install utils
De momento he creado un script que permite la instalacion de algunas librerias utiles tanto en fedora como en ubuntu. 

Para utilizar este script inserta lo siguiente en la terminal.

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/csidevrik/prj-bash/main/scripts.d/install-utils/install.sh)"
```

Tambien adjunto el script para ohmyzsh, es que sino tengo que estar ingresando al sitio de oh my zsh

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Install go
Para conseguir mas velocidad al intervenir sobre un server necesito usar go sobre el server, hasta el momento he habilitado sobre ubuntu, creo que el script va a poder correr en cualquier linux ya lo voy a probar en vm de fedora, rocky, alma y ubuntu, sobre arch linux me faltaria pero de momento te comparto para que solo lo copies y pegues en tu terminal y tendras instalado una version de go sobre tu ubuntu segun tu version, revisa el folder del repo, aqui esta .

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/csidevrik/prj-bash/refs/heads/main/scripts.d/install-go/ubu/installgo1.25on20.04.sh)"
```