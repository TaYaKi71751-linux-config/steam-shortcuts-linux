#!/bin/bash

WIDEVINECDM_PATHS=`sudo find ~/ -type d -name 'WidevineCdm'`
while IFS= read -r widevinecdm_path
do
	WIDEVINECDM_VERSION_PATHS=`sudo find ${widevinecdm_path} -type d -name '*.*' -maxdepth 1`
	while IFS= read -r widevinecdm_version_path
	do
		if [ -n "${widevinecdm_version_path}" ];then
			echo ${widevinecdm_version_path}
			echo sudo chown -R root:root ${widevinecdm_version_path}
			sudo chown -R root:root ${widevinecdm_version_path}
		fi
	done < <(printf '%s\n' "$WIDEVINECDM_VERSION_PATHS")
done < <(printf '%s\n' "$WIDEVINECDM_PATHS")
