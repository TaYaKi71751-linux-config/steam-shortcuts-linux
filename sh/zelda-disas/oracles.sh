#!/bin/bash

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

sudo_executor pacman -Sy
sudo_executor pacman -S python3 --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S python-yaml --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S python-sphinx --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S cmake --noconfirm --overwrite \\\'*\\\'
FIRST_PATH=`pwd`


cd $HOME
git clone https://github.com/vhelin/wla-dx
cd wla-dx
mkdir -p build
cd build
if ( ls build/binaries );then
	echo Already built
else
	cmake ..
	cmake --build . --config Release
fi
cd binaries

export PATH=$PATH:$PWD

cd $HOME
git clone https://github.com/Stewmath/oracles-disasm.git
cd oracles-disasm
make -j$(nproc) ages
make -j$(nproc) seasons

function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}

cd "${FIRST_PATH}"
auto_path node
auto_path pnpm
auto_path ts-node

pnpm i
ts-node ./add/SameBoy.ts
kill -9 $(pgrep steam)
pkill steam
