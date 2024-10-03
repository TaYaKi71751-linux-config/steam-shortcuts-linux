#!/bin/bash

cd $HOME
mkdir -p CurseForge
cd CurseForge
rm curseforge-latest-linux.zip
rm -rf curseforge-latest-linux
wget https://curseforge.overwolf.com/downloads/curseforge-latest-linux.zip
unzip curseforge-latest-linux.zip
