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

PKGBUILD_DEPENDS="$(bash -c 'source PKGBUILD; printf "%s\n" "${depends[@]}"')"
function install_dep(){
  dep="$1"
  pacman_log="$(mktemp)"
  sudo pacman -S --overwrite '*' "${dep}" --noconfirm 2>&1 | tee "${pacman_log}" || true
  if grep -q 'not found' "${pacman_log}";then
    yay -S "${dep}" --noconfirm
  fi
  rm -f "${pacman_log}"
}

function install_x86_64_dep(){
  dep="$1"
  if [ "${dep}" = "nettle3" ];then
    sudo pacman -U 'https://archlinux.org/packages/extra/x86_64/nettle3/download/' --noconfirm --overwrite '*'
  else
    install_dep "${dep}"
  fi
}

for dep in ${PKGBUILD_DEPENDS};do
  echo "Installing dep: ${dep}"
  install_dep "${dep}"
done

if grep -q "arch\=\(\'x86_64\'\)" PKGBUILD;then
  PKGBUILD_X86_64_DEPENDS="$(bash -c 'source PKGBUILD; printf "%s\n" "${depends_x86_64[@]}"')"
  for dep in ${PKGBUILD_X86_64_DEPENDS};do
    echo "Installing x86_64 dep: ${dep}"
    install_x86_64_dep "${dep}"
  done
fi
sed -i -z 's|\tinstall -d[^\n]*\n||g' PKGBUILD

sed -i "s|/usr/share/steam/compatibilitytools.d/|$HOME/.local/share/Steam/compatibilitytools.d/|g" PKGBUILD

makepkg -si --noconfirm
