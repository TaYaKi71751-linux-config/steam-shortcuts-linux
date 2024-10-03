#!/bin/bash

cd $HOME
cd CurseForge || exit -1

find . -name 'CurseForge*.AppImage' -type f -exec {} \;
