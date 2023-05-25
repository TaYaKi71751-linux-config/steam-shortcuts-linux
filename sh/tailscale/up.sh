#!/bin/bash

TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --reset "
TAILSCLAE_OPTIONS="${TAILSCLAE_OPTIONS} --exit-node=${TAILSCALE_EXIT_NODE} "
TAILSCLAE_OPTIONS="${TAILSCLAE_OPTIONS} --ssh "
TAILSCLAE_OPTIONS="${TAILSCLAE_OPTIONS} --operator=${HOSTNAME} "
if [ -n "${TAILSCALE_EXIT_NODE}" ];then
	TAILSCLAE_OPTIONS="${TAILSCLAE_OPTIONS} --exit-node-allow-lan-access "
fi


function up(){
	DAEMON_STATUS=`sudo ps -A | grep tailscaled`
	if [ -n "${DAEMON_STATUS}" ];then
		echo ${TAILSCLAE_OPTIONS}
		sudo tailscale up ${TAILSCLAE_OPTIONS}
	else
		sudo systemd-run tailscaled
		up
	fi
}
up
