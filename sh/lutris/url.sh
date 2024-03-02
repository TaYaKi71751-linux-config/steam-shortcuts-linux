#!/bin/bash

mkdir -p $HOME/.var/app/net.lutris.Lutris/cache/lutris/installer/

SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}
auto_path wine

if [ -z "${LUTRIS_DEEPLINK_URL}" ];then
	"flatpak" "run" "net.lutris.Lutris"
else
	"flatpak" "run" "net.lutris.Lutris" "${LUTRIS_DEEPLINK_URL}"
fi
