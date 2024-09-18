#!/bin/bash

SHELL_RUN_COMMANDS=`find	~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

ORIG_HOME=${HOME}

# https://github.com/ValveSoftware/SteamOS/issues/1039
function check_kdialog(){
	export KDIALOG_USABLE=$(find / -name 'kdialog' -type f -exec {} --help \;)
	export KDIALOG_USABLE="$(echo $KDIALOG_USABLE | grep Usage)"
}

function check_zenity(){
	export ZENITY_USABLE=`find / -name 'zenity' -type f -exec {} --help \;`
	export ZENITY_USABLE="$(echo $ZENITY_USABLE | grep Usage)"
	env | grep STEAM_DECK\= && unset $ZENITY_USABLE
}
check_kdialog
check_zenity

function get_password(){
	if [ -n "${KDIALOG_USABLE}" ];then
		find / -name 'kdialog' -type f -exec bash -c "{} --password 'Enter Password' && pkill find " \;
	elif [ -n "${ZENITY_USABLE}" ];then
		find / -name 'zenity' -type f -exec bash -c "{} --password && pkill find"
	fi
}


function check_sudo() {
	if ( `sudo -nv` );then
		return "0"
	fi
	export SUDO_PASSWORD=$(get_password)
	# https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh…
	if ( echo ${SUDO_PASSWORD} | sudo -S echo A | grep A );then
		export SUDO_PASSWORD=${SUDO_PASSWORD}
	else
		check_sudo
	fi
}
check_sudo

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
function sudo_executor(){
	if ( `sudo -nv` );then
		sudo $@
	else
		echo ${SUDO_PASSWORD} | sudo -S $@
	fi
}
function user_install_flatpak_package(){
	PACKAGE_NAME="$1"
RESULT="$(bash << EOF
flatpak install --user ${PACKAGE_NAME} --assumeyes
EOF
)"
if ( echo ${RESULT} | grep already\ installed );then
	echo A
	return
elif ( echo ${RESULT} | grep ${PACKAGE_NAME} | grep Similar );then
	PACKAGE_LINES="$(echo "${RESULT}" | grep "${PACKAGE_NAME}/")"
while IFS= read -r line
do
bash << EOF
	flatpak install --user $(echo $line | rev | cut -d ' ' -f1 | rev) --assumeyes
EOF
done < <(printf '%s\n' "$PACKAGE_LINES")
fi

}

function system_install_flatpak_package(){
	PACKAGE_NAME="$1"
RESULT="$(bash << EOF
flatpak install --system ${PACKAGE_NAME} --assumeyes
EOF
)"
if ( echo ${RESULT} | grep already\ installed );then
	echo A
	return
elif ( echo ${RESULT} | grep ${PACKAGE_NAME} | grep Similar );then
	PACKAGE_LINES="$(echo "${RESULT}" | grep "${PACKAGE_NAME}/")"
while IFS= read -r line
do
bash << EOF
	flatpak install --system $(echo $line | rev | cut -d ' ' -f1 | rev) --assumeyes
EOF
done < <(printf '%s\n' "$PACKAGE_LINES")
fi

}

system_install_flatpak_package com.obsproject.Studio.Plugin.OBSVkCapture
system_install_flatpak_package org.freedesktop.Platform.VulkanLayer.OBSVkCapture
system_install_flatpak_package com.obsproject.Studio

sudo_executor pacman -Sy obs-studio --noconfirm
sudo_executor pacman -Sy $(pacman -Qq | grep vulkan) --noconfirm --overwrite \\\'*\\\'

cd ~/
git clone https://github.com/nowrep/obs-vkcapture
cd obs-vkcapture
git pull
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release ..
make 
touch ~/.bashrc
find ~/ -type f -name '.*shrc' -maxdepth 1 -exec sh -c 'grep -w "export PATH=\${PATH}:$(pwd)$" {} || echo "export PATH=\${PATH}:$(pwd)" >> {}' \;
export PATH=${PATH}:$(pwd)
sudo_executor cp obs-gamecapture /usr/bin/
sudo_executor cp obs-vkcapture /usr/bin/

which obs-gamecapture && exit 0

if ( which yay );then
	yay -S obs-vkcapture-git --noconfirm
fi
uname -a | grep x86_64 || exit
sudo_executor pacman -U --noconfirm - << EOF
https://archlinux.org/packages/core/any/archlinux-keyring/download/
EOF
sudo_executor pacman -U --noconfirm - << EOF
https://archlinux.org/packages/core/x86_64/glibc/download/
https://archlinux.org/packages/core/x86_64/lib32-glibc/download/
EOF

which obs-gamecapture && exit 0

uname -a | grep x86_64 || exit


sudo_executor pacman -S chaotic-aur/obs-vkcapture-git --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -U --noconfirm - << EOF
https://archlinux.org/packages/core/any/archlinux-keyring/download/
EOF
sudo_executor pacman -U --noconfirm - << EOF
https://archlinux.org/packages/core/x86_64/glibc/download/
https://archlinux.org/packages/core/x86_64/lib32-glibc/download/
EOF
