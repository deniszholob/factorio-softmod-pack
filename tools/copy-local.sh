#!/bin/bash
# Usage: bash tools/copy-local.sh
# Be carefull about editing in factorio folder, as this will overwrite anything there

FACTORIO_DIR="$APPDATA/Factorio/scenarios"
RELEASE_FILE_NAME="dddgamer-softmod-pack-dev"

echo "===== Current dir:"
pwd #output: your-path-to-this-repository/factorio-softmod-pack
# ls -al

echo "Remove previous contents"
rm -rfv "$FACTORIO_DIR/$RELEASE_FILE_NAME"

echo "===== Copy scr folder to factorio scenario folder"
# Copies everything including dot files/folders
cp -rfv "./src" "$FACTORIO_DIR/$RELEASE_FILE_NAME"

echo "===== Copied folder contents:"
ls -al "$FACTORIO_DIR/$RELEASE_FILE_NAME"
