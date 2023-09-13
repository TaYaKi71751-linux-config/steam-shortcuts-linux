#!/bin/bash
#
SHELL_RUN_COMMANDS=`find ~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	source ${shrc}
done

source ./enable-solo-lobby.sh
source ./disable-solo-lobby.sh
