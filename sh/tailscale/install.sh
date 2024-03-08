#!/bin/bash

#version
TAILSCALE_TARGET_VERSION="$(pacman -Ss tailscale | grep /tailscale | rev | cut -d ' ' -f1 | rev | cut -d '-' -f1 )"
echo ${TAILSCALE_TARGET_VERSION}

which tailscale && exit

#tailscale
mkdir -p ~/.local/tailscale/git
cd ~/.local/tailscale/git
mkdir -p tailscale
cd tailscale
git init
git remote add origin https://github.com/tailscale/tailscale.git
git add -A
git reset --hard HEAD
git checkout v${TAILSCALE_TARGET_VERSION}
git remote update
git checkout v${TAILSCALE_TARGET_VERSION}
./build_dist.sh tailscale.com/cmd/tailscale
./build_dist.sh tailscale.com/cmd/tailscaled
touch ~/.bashrc
find ~/ -type f -name '.*shrc' -maxdepth 1 -exec sh -c 'grep -w "export PATH=\${PATH}:$(pwd)$" {} || echo "export PATH=\${PATH}:$(pwd)" >> {}' \;
export PATH=${PATH}:$(pwd)

which tailscale && exit
uname -a | grep x86_64 || exit

mkdir -p ~/.local/tailscale/bin
cd ~/.local/tailscale/bin
wget https://pkgs.tailscale.com/stable/tailscale_1.24.2_amd64.tgz
tar xzf tailscale_1.24.2_amd64.tgz
cd tailscale_1.24.2_amd64
touch ~/.bashrc
find ~/ -type f -name '.*shrc' -maxdepth 1 -exec sh -c 'grep -w "export PATH=\${PATH}:$(pwd)$" {} || echo "export PATH=\${PATH}:$(pwd)" >> {}' \;
export PATH=${PATH}:$(pwd)
