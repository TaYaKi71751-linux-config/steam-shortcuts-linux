#!/bin/bash

mkdir -p ${HOME}/.local
cd ${HOME}/.local

which git || exit -1

git clone https://github.com/JGRennison/OpenTTD-patches.git
cd ${HOME}/.local/OpenTTD-patches/ || exit -1

git pull

mkdir -p ${HOME}/.local/OpenTTD-patches/build-bin
cd ${HOME}/.local/OpenTTD-patches/build-bin

which cmake || exit -1
which make || exit -1
cmake ..
make -j $(nproc)

