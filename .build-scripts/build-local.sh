#!/bin/bash

FACTORIO_DIR="$APPDATA/Factorio/scenarios"
RELEASE_FILE_NAME="dddgamer-softmod-pack"

echo "===== Current dir:"
pwd # your-path-to-this-repository/factorio-softmod-pack
# ls -al

echo "Remove previous contents"
rm -rfv "$FACTORIO_DIR/$RELEASE_FILE_NAME"

# echo "===== Copy Repo folder..."
# Copies everything including dot files/folders
# cp -rfv "./" "$FACTORIO_DIR/$RELEASE_FILE_NAME"

echo "===== Copy Repo folder..."
# Make dir and tar/untar to copy contents without the dot file/folders
# https://stackoverflow.com/questions/2193584/copy-folder-recursively-excluding-some-folders
mkdir -p "$FACTORIO_DIR/$RELEASE_FILE_NAME"
tar cfv - --exclude=".[^/]*" . | (cd "$FACTORIO_DIR/$RELEASE_FILE_NAME" && tar xvf - )

echo "===== Copied folder contents:"
ls -al "$FACTORIO_DIR/$RELEASE_FILE_NAME"

