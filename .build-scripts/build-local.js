#!/usr/bin/env node

// === Imports === //
const fs = require('fs');
const process = require('process');

// === Consts === //
const FACTORIO_DIR = `${process.env.APPDATA}/Factorio/scenarios`;
const RELEASE_FILE_NAME = "dddgamer-softmod-pack";

const args = process.argv.slice(2);
const fileDir = args[0];

if (!fileDir) { showInfo(); }


function main() {
    console.log(FACTORIO_DIR);
}


function showInfo() {
    console.log(`No, Factorio directory was given, using "${FACTORIO_DIR}"`);
}

main();
