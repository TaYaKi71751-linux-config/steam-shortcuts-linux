#!/bin/bash

function check_sudo() {
	sudo -nv && exit
	SUDO_PASSWORD="$(zenity --password)"
	# https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh…
	if ( echo ${SUDO_PASSWORD} | sudo -S echo A | grep A );then
		export SUDO_PASSWORD=${SUDO_PASSWORD}
	else
		check_sudo
	fi
}
check_sudo

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo echo \${SUDO_PASSWORD} \| sudo -S)"


SHELL_RUN_COMMANDS=`find ~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

function down(){
SHELL_RUN_COMMANDS=`find ~ -maxdepth 1 -name '.*shrc' || true`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done
	DAEMON_STATUS=`ps -A | grep tailscaled`
	if [ -n "${DAEMON_STATUS}" ];then
		echo "tailscaled already running"
		find / -name 'tailscale' -type f -exec ${SUDO_EXECUTOR} tailscale down \; || true
	else
		echo "tailscaled not running, run tailscaled"
		find / -name 'tailscaled' -type f -exec ${SUDO_EXECUTOR} systemd-run {} \; || true
		down
	fi
}

down

