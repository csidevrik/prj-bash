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

### Setup testing on rocky linux
Ahora hemos trabajado en un script nuevo para los servidores en linux, ahora voy a probar en rocky linux 10 para saber si funciona o no.
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/csidevrik/prj-bash/main/scripts.d/setup-utils/setup.sh)"
```




### Install go
Para conseguir mas velocidad al intervenir sobre un server necesito usar go sobre el server, hasta el momento he habilitado sobre ubuntu, creo que el script va a poder correr en cualquier linux ya lo voy a probar en vm de fedora, rocky, alma y ubuntu, sobre arch linux me faltaria pero de momento te comparto para que solo lo copies y pegues en tu terminal y tendras instalado una version de go sobre tu ubuntu segun tu version, revisa el folder del repo, aqui esta .

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/csidevrik/prj-bash/refs/heads/main/scripts.d/install-go/ubu/go1.25on20.04/install.sh)"
```

### Create nvim config
Scripts para desplegar automaticamente una configuracion de Neovim con lazy.nvim, LSP y soporte para programar en Go. Funcionan sobre Fedora/RHEL (dnf) y Ubuntu/Debian (apt). Si ya tienes una configuracion en `~/.config/nvim`, el script hace un backup antes de reemplazarla.

Primero revisa tu version de Neovim con `nvim --version` y elige el script:

| | install5.sh | install6.sh |
|---|---|---|
| Version de Neovim | anteriores a 0.11 | 0.11 o superior (si no, se detiene y recomienda install5.sh) |
| Configuracion del LSP | `require('lspconfig')` (forma antigua, en 0.11 muestra aviso de obsoleto) | `vim.lsp.config()` + `vim.lsp.enable()` (API nativa de 0.11) |
| nvim-treesitter | sin rama fijada (falla con el error `nvim-treesitter.configs not found`) | rama `master` fijada |
| Mensajes "Press ENTER" al abrir | si, por `print()` en la configuracion | no |
| Errores visibles junto al codigo | por defecto de Neovim | activados (`virtual_text`) |
| Dependencias instaladas | neovim, git, golang | neovim, git, gcc, make, ripgrep, fd, curl, unzip, golang |
| Plugins | catppuccin (y otros temas), nvim-tree, telescope, treesitter, nvim-cmp, lualine, autopairs, Comment.nvim, nvim-lspconfig | los mismos sin Comment.nvim (0.11 ya trae `gc`) + which-key + gitsigns |
| Go | gopls, autoformato al guardar, `:GoRun` `:GoTest` `:GoBuild` `:GoTestFunc` | lo mismo |
| Instala los plugins al final | no, lo hace al abrir nvim la primera vez | si (`Lazy! sync`) |
| Formatear | `<Space>f` | `<Space>lf` |
| Ejecutar con sudo | lo permite | lo bloquea, ejecutalo con tu usuario normal |

Para Neovim 0.11 o superior:

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/csidevrik/prj-bash/main/scripts.d/create-nvimconfig/install6.sh)"
```

Para versiones anteriores de Neovim:

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/csidevrik/prj-bash/main/scripts.d/create-nvimconfig/install5.sh)"
```

Al terminar, recarga tu shell (`source ~/.zshrc` o abre una terminal nueva) para que Neovim encuentre `gopls`.
