#!/bin/bash

TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --reset "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --exit-node=${TAILSCALE_EXIT_NODE} "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --ssh "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --operator=${HOSTNAME} "
if [ -n "${TAILSCALE_EXIT_NODE}" ];then
	TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --exit-node-allow-lan-access "
fi


function up(){
	DAEMON_STATUS=`sudo ps -A | grep tailscaled`
	if [ -n "${DAEMON_STATUS}" ];then
		echo ${TAILSCALE_OPTIONS}
		sudo tailscale up ${TAILSCALE_OPTIONS}
	else
		sudo systemd-run tailscaled
		up
	fi
}
up
