#!/bin/bash

sudo pacman -Syu gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav --noconfirm --overwrite '*'
yay -Sy gst-plugin-fdk_aac --noconfirm --overwrite '*'
yay -Sy opentaikohub-bin --noconfirm --overwrite '*'
sudo mkdir -p /usr/lib/OpenTaiko-Hub/
sudo chown $USER:$USER -R /usr/lib/OpenTaiko-Hub/
