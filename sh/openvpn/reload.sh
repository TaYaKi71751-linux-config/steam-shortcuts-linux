#!/bin/bash

SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

find / -name 'pnpx' -type f -exec bash -c "{} ts-node ./add/openvpn.ts && pkill find" \;
pkill steam
