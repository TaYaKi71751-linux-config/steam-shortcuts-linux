#!/bin/sh

SHELL_RUN_COMMANDS=`find ~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	source ${shrc}
done

sudo systemctl enable iptables --now
