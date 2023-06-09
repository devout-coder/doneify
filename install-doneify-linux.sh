#!/bin/bash

# Exit if any command fails
set -e

# Echo all commands for debug purposes
set -x

flutter build linux

sudo mkdir -p /opt/doneify 
sudo cp -rf build/linux/x64/release/bundle/* /opt/doneify

sudo cp /opt/doneify/data/flutter_assets/assets/images/doneify_logo.png /usr/share/pixmaps

sudo ln -s /opt/doneify/Doneify /usr/bin/Doneify
sudo cp ./packaging/linux/Doneify.desktop /usr/share/applications/Doneify.desktop