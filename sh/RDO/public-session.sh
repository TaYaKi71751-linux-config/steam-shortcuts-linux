#!/bin/bash

sudo pkill RDR2.exe
sudo pkill PlayRDR2.exe

RDR2_PATHS="$(find / 2> /dev/null | grep PlayRDR2.exe)"

echo ${RDR2_PATHS}
while IFS= read -r PLAY_RDR2_PATH
do
	RDR2_PATH=`dirname "${PLAY_RDR2_PATH}"`
	STARTUP_PATH="${RDR2_PATH}/x64/data/startup.meta"
	if [ -d "$(dirname '${STARTUP_PATH}')" ];then
		if [ -f "${STARTUP_PATH}" ];then
			rm "${STARTUP_PATH}"
		fi
	else
		continue
	fi
	# https://unix.stackexchange.com/questions/9784/how-can-i-read-line-by-line-from-a-variable-in-bash
done < <(printf '%s\n' "${RDR2_PATHS}")
