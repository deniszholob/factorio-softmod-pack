#!/bin/bash

# Repo thats buing built...
REPO_NAME="deniszholob/factorio-softmod-pack"
# Make sure this is the same as the file in .travis.yml
RELEASE_FILE_NAME="dddgamer-softmod-pack"

echo "===== Current dir:"
pwd # /home/travis/build/$REPO_NAME
ls -al

# Go to the build directory so we can copy
# the repo contents in to a release folder
# so we dont mess with the repo itself
cd ~/build || exit

echo "===== Changed dir to:"
pwd # /home/travis/build/
ls -al

# Create a release folder from the repo contents
echo "===== Copy Repo folder..."
cp -rf $REPO_NAME $RELEASE_FILE_NAME
ls -al

echo "===== Copied folder contents:"
ls -al $RELEASE_FILE_NAME

echo "===== Remove files that start with . (dev files)..."
# delete all files starting with a dot containing at least two other characters,
# thus leaving . and .. intact
find $RELEASE_FILE_NAME -iname ".*"
# https://www.cyberciti.biz/faq/bash-linux-unix-delete-hidden-files-directories-command/
find $RELEASE_FILE_NAME -iname ".*" -exec rm -rf {} \;

echo "===== Copied folder contents:"
ls -al $RELEASE_FILE_NAME

# Zip
echo "===== Creating zip..."
zip -r9q "$HOME/build/$REPO_NAME/$RELEASE_FILE_NAME.zip" $RELEASE_FILE_NAME
