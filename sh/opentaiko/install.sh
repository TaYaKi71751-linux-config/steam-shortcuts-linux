#!/bin/bash

sudo pacman -Syu gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav --noconfirm --overwrite '*'
gst-inspect-1.0 autoaudiosink
yay -Sy gst-plugin-fdk_aac --noconfirm --overwrite '*'
gst-inspect-1.0 fdkaacdec
yay -Sy opentaikohub-bin --noconfirm --overwrite '*'
