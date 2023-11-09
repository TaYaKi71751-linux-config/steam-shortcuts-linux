#!/bin/bash

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo pkexec)"

echo ${SUDO_EXECUTOR} | tee ~/log.sudo_exe

SHELL_RUN_COMMANDS=`find ~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

find / -name 'pnpm' -type f -exec bash -c "{} i && pkill find" \;
find / -name 'pnpm' -type f -exec bash -c "{} add:steam && ${SUDO_EXECUTOR} env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pkill find" \;

