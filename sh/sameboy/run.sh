#!/bin/bash

mkdir -p $HOME/.var/app/net.lutris.Lutris/cache/lutris/installer/

if [ -z "${SAMEBOY_ROM_PATH}" ];then
	"flatpak" "run" "io.github.sameboy.SameBoy"
else
	"flatpak" "run" "io.github.sameboy.SameBoy" "${SAMEBOY_ROM_PATH}"
fi
