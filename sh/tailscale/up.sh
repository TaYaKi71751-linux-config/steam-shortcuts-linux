#!/bin/bash

ORIG_HOME=${HOME}

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo pkexec)"
echo $SUDO_EXECUTOR
SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --reset "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --exit-node=${TAILSCALE_EXIT_NODE} "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --ssh "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --operator=${HOSTNAME} "
if [ -n "${TAILSCALE_EXIT_NODE}" ];then
	TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --exit-node-allow-lan-access "
fi

function up(){
# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo pkexec)"
echo $SUDO_EXECUTOR
SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

	DAEMON_STATUS=`ps -A | grep tailscaled || true`
	if [ -n "${DAEMON_STATUS}" ];then
		echo "tailscaled already running"
		echo ${TAILSCALE_OPTIONS}
		find / -name 'tailscale' -type f -exec ${SUDO_EXECUTOR} bash -c "{} up ${TAILSCALE_OPTIONS} && pkill find" \; || true
	else
		echo "tailscaled not running, run tailscaled"
		find / -name 'tailscaled' -type f -exec ${SUDO_EXECUTOR} systemd-run {} \; || true
		up
	fi
}
up
