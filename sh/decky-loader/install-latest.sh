#!/bin/bash

find / -type f -name 'curl' -exec bash -c "{} -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh" && pkill find  \;
find / -type f -name 'pkill' -exec {} -9 steam && {} find \;
find / -type f -name 'pkill' -exec {} steam && {} find \;
