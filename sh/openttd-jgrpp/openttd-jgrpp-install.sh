#!/bin/bash

SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}

# https://github.com/ValveSoftware/SteamOS/issues/1039
function check_kdialog(){
	if ( which kdialog );then
		export KDIALOG_USABLE="true"
	else
		unset KDIALOG_USABLE
	fi
}

function check_zenity(){
	if ( which zenity );then
		export ZENITY_USABLE="true"
	else
		unset ZENITY_USABLE="true"
	fi
	env | grep STEAM_DECK\= && unset $ZENITY_USABLE
}
check_kdialog
check_zenity

function get_password(){
	if [ -n "${KDIALOG_USABLE}" ];then
		kdialog --password 'Enter Password'
	elif [ -n "${ZENITY_USABLE}" ];then
		zenity --password
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

sudo_executor pacman -Sy fluidsynth --noconfirm
sudo_executor pacman -Sy fontconfig --noconfirm
sudo_executor pacman -Sy hicolor-icon-theme --noconfirm
sudo_executor pacman -Sy lzo --noconfirm
sudo_executor pacman -Sy cmake --noconfirm
sudo_executor pacman -Sy ninja --noconfirm

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

