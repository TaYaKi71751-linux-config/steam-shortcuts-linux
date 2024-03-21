#!/bin/bash

mkdir -p $HOME/.var/app/net.lutris.Lutris/cache/lutris/installer/

if [ -z "${LUTRIS_DEEPLINK_URL}" ];then
	"flatpak" "run" "net.lutris.Lutris"
else
	"flatpak" "run" "net.lutris.Lutris" "${LUTRIS_DEEPLINK_URL}"
fi
