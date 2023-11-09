#!/bin/bash

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo pkexec)"

function process_kill() {
sudo pkill GTA5.exe
sudo pkill PlayGTAV.exe
}
# https://unix.stackexchange.com/questions/269078/executing-a-bash-script-function-with-sudo
PROCESS_KILL_FUNC=$(declare -f process_kill)
${SUDO_EXECUTOR} bash -c "$PROCESS_KILL_FUNC; process_kill"

GTAV_PATHS="$(find / 2> /dev/null | grep PlayGTAV.exe)"

echo ${GTAV_PATHS}
while IFS= read -r PLAY_GTAV_PATH
do
	GTAV_PATH=`dirname "${PLAY_GTAV_PATH}"`
	STARTUP_PATH="${GTAV_PATH}/x64/data/startup.meta"
	if [ -d "$(dirname '${STARTUP_PATH}')" ];then
		if [ -f "${STARTUP_PATH}" ];then
			rm "${STARTUP_PATH}"
		fi
	else
		continue
	fi
	if [ -d "$(dirname '${BOOT_LAUNCHER_FLOW_PATH}')" ];then
		if [ -f "${BOOT_LAUNCHER_FLOW_PATH}" ];then
			rm "${BOOT_LAUNCHER_FLOW_PATH}"
		fi
	else
		continue
	fi
	# https://unix.stackexchange.com/questions/9784/how-can-i-read-line-by-line-from-a-variable-in-bash
done < <(printf '%s\n' "${GTAV_PATHS}")

