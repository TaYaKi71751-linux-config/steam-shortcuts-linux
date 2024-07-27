#!/bin/bash

rm -rf $HOME/.var/app/com.mojang.Minecraft/.minecraft
mkdir -p $HOME/.minecraft
ln -sf $HOME/.minecraft $HOME/.var/app/com.mojang.Minecraft/

flatpak run com.mojang.Minecraft
