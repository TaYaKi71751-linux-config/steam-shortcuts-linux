#!/bin/bash

SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

ORIG_HOME=${HOME}

function check_sudo() {
	if ( `sudo -nv` );then
		return "0"
	fi
	export SUDO_PASSWORD="$(zenity --password)"
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
konsole -e echo ${SUDO_EXECUTOR} | tee ~/log

TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --reset "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --exit-node=${TAILSCALE_EXIT_NODE} "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --ssh "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --operator=${HOSTNAME} "
if [ -n "${TAILSCALE_EXIT_NODE}" ];then
	TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --exit-node-allow-lan-access "
fi

function up(){
	DAEMON_STATUS=`ps -A | grep tailscaled || true`
	if [ -n "${DAEMON_STATUS}" ];then
		echo "tailscaled already running"
		echo ${TAILSCALE_OPTIONS}
		find / -name 'tailscale' -type f -exec ${SUDO_EXECUTOR} {} up ${TAILSCALE_OPTIONS} \; || true
	else
		echo "tailscaled not running, run tailscaled"
		find / -name 'tailscaled' -type f -exec ${SUDO_EXECUTOR} systemd-run {} \; || true
		up
	fi
}
up
