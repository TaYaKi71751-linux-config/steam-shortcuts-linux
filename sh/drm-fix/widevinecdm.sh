#!/bin/bash

#function main() {
function loop_func(){
		export WIDEVINECDM_VERSION_PATHS=`find ${widevinecdm_path} -type d -name '*.*' -maxdepth 1`
		while IFS= read -r widevinecdm_version_path
		do
			if [ -n "${widevinecdm_version_path}" ];then
				echo ${widevinecdm_version_path}
				echo sudo_executor chown -R root:root ${widevinecdm_version_path}
				sudo_executor chown -R root:root ${widevinecdm_version_path}
			fi
		done < <(printf '%s\n' "$WIDEVINECDM_VERSION_PATHS")
}
FUNC=$(declare -f loop_func)

