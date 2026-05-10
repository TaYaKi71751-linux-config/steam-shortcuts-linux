#!/bin/bash
set -e

cd "$HOME"

if [ ! -d dwproton-bin ]; then
  git clone https://aur.archlinux.org/dwproton-bin.git
fi

cd dwproton-bin
git reset --hard HEAD
git pull

rm -f ./*.pkg.tar.zst

sed -i -z 's|\tinstall -d[^\n]*\n||g' PKGBUILD

sed -i "s|/usr/share/steam/compatibilitytools.d/|$HOME/.local/share/Steam/compatibilitytools.d/|g" PKGBUILD

makepkg -si --noconfirm