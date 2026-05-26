#!/bin/bash

ORIG_HOME=${HOME}
SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

function get_password(){
	if ( which kdialog );then
		kdialog --password 'Enter password'
	elif ( which zenity );then
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


function auto_path() {
	TARGET_PATHS="$(find $HOME -name "$1" -type f 2>/dev/null)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}
auto_path tailscaled
auto_path tailscale

which tailscaled || exit -1
which tailscale || exit -1

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
function sudo_executor(){
	if ( `sudo -nv` );then
		sudo $@
	else
		echo ${SUDO_PASSWORD} | sudo -S $@
	fi
}

function logout(){
	DAEMON_STATUS=`ps -A | grep tailscaled || true`
	if [ -n "${DAEMON_STATUS}" ];then
		echo "tailscaled already running"
		echo ${TAILSCALE_OPTIONS}
		while IFS= read -r line
		do
			sudo_executor "$line" logout
		done <<< "$(find $HOME -name 'tailscale' -type f 2>/dev/null)"
	else
		echo "tailscaled not running, run tailscaled"
		while IFS= read -r line
		do
			sudo_executor systemd-run "$line"
		done <<< "$(find $HOME -name 'tailscaled' -type f 2>/dev/null)"
		logout
	fi
}
logout
