#!/bin/bash

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
down
