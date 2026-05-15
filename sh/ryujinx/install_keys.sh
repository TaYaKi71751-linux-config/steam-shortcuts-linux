#!/bin/bash

touch ~/.bashrc

SHELL_RUN_COMMANDS=`find	~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

ORIG_HOME=${HOME}

# https://github.com/ValveSoftware/SteamOS/issues/1039
function check_kdialog(){
	export KDIALOG_USABLE=$(find / -name 'kdialog' -type f -exec {} --help \;)
	export KDIALOG_USABLE="$(echo $KDIALOG_USABLE | grep '\-\-help')"
}

function check_zenity(){
	export ZENITY_USABLE=`find / -name 'zenity' -type f -exec {} --help \;`
	export ZENITY_USABLE="$(echo $ZENITY_USABLE | grep '\-\-help')"
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
if ( which wget );then
	echo Already installed wget
else
	sudo_executor pacman -S wget --noconfirm --overwrite \\\'*\\\'
fi
if ( which unzip );then
	echo ALready installed unzip
else
	sudo_executor pacman -S unzip --noconfirm --overwrite \\\'*\\\'
fi

echo mkdir -p ${HOME}/.var/app/org.ryujinx.Ryujinx/config/Ryujinx/system
mkdir -p ${HOME}/.var/app/org.ryujinx.Ryujinx/config/Ryujinx/system
echo cd ${HOME}/.var/app/org.ryujinx.Ryujinx/config/Ryujinx/system
cd ${HOME}/.var/app/org.ryujinx.Ryujinx/config/Ryujinx/system

echo wget https://prodkeys.net/wp-content/uploads/2024/04/ProdKeys.net-v18.0.0.zip -q --show-progress
wget https://prodkeys.net/wp-content/uploads/2024/04/ProdKeys.net-v18.0.0.zip -q --show-progress
echo unzip *.zip
unzip *.zip
echo rm *.zip
rm *.zip
