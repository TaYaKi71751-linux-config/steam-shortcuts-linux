#!/bin/bash

function down(){
	DAEMON_STATUS=`sudo ps -A | grep tailscaled`
	if [ -n "${DAEMON_STATUS}" ];then
		sudo tailscale down
	else
		sudo systemd-run tailscaled
		down
	fi
}
down
