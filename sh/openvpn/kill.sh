#!/bin/bash

SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

ORIG_HOME=${HOME}

function check_openvpn(){
	export OPENVPN_USABLE=`find / -name 'openvpn' -type f -exec {} --help \;`
	export OPENVPN_USABLE="$(echo $OPENVPN_USABLE | grep OpenVPN)"
}
check_openvpn

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

if [ -z "${OPENVPN_USABLE}" ];then
	if [ -n "${KDIALOG_USABLE}" ];then
		find / -name 'kdialog' -type f -exec bash -c "{} --error 'openvpn binary not found. please install openvpn.' && pkill find" \;
	elif [ -n "${ZENITY_USABLE}" ];then
		find / -name 'zenity' -type f -exec bash -c "{} --error --text='openvpn binary not found. please install openvpn.' && pkill find" \;
	fi
fi

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
export SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo "echo \${SUDO_PASSWORD} \| sudo -S")"

${SUDO_EXECUTOR} sysctl -w net.ipv6.conf.all.disable_ipv6=0
${SUDO_EXECUTOR} pkill openvpn
