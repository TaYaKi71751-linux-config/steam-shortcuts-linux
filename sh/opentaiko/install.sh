#!/bin/bash

mkdir -p $HOME/opentaiko
cd $HOME/opentaiko
rm OpenTaiko.Linux.x64.zip
curl -LsSf https://github.com/0auBSQ/OpenTaiko/releases/latest/download/OpenTaiko.Linux.x64.zip -o OpenTaiko.Linux.x64.zip > /dev/null 2>&1
rm -rf publish
unzip OpenTaiko.Linux.x64.zip > /dev/null 2>&1
chmod +x publish/OpenTaiko

echo "OpenTaiko installed successfully!"
