#!/usr/bin/env node

const yargs = require("yargs");

// Aquí puedes definir comandos y opciones
yargs.command('comando', 'Descripción del comando', (yargs) => {
    // Definición de opciones para el comando
}, (argv) => {
    // Acciones a realizar con argv
});

// Otras configuraciones de yargs, si las necesitas
yargs.parse();
