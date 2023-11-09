#!/bin/bash

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo pkexec)"


SHELL_RUN_COMMANDS=`find ~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

function down(){
	DAEMON_STATUS=`sudo ps -A | grep tailscaled`
	if [ -n "${DAEMON_STATUS}" ];then
		echo "tailscaled already running"
		sudo tailscale down
	else
		echo "tailscaled not running, run tailscaled"
		sudo systemd-run tailscaled
		down
	fi
}

# https://unix.stackexchange.com/questions/269078/executing-a-bash-script-function-with-sudo
FUNC=$(declare -f down)
${SUDO_EXECUTOR} bash -c "$(env) ; $FUNC; down"

