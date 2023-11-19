#!/bin/bash

SHELL_RUN_COMMANDS=`find ~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done
find / -name 'pnpm' -type f -exec bash -c "{} i && pkill find" \;
find / -name 'pnpm' -type f -exec bash -c "{} add:steam && pkill find" \;
kill -9 $(pgrep steam)
pkill steam
