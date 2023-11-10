#!/bin/bash

function check_sudo() {
	if ( `sudo -nv` );then
		return "0"
	fi
	SUDO_PASSWORD="$(zenity --password)"
	# https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh…
	if ( echo ${SUDO_PASSWORD} | sudo -S echo A | grep A );then
		export SUDO_PASSWORD=${SUDO_PASSWORD}
	else
		check_sudo
	fi
}
check_sudo

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
export SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo echo \${SUDO_PASSWORD} \| sudo -S)"

export ORIG_HOME="${HOME}"
#function main() {
function loop_func(){
		export WIDEVINECDM_VERSION_PATHS=`find ${widevinecdm_path} -type d -name '*.*' -maxdepth 1`
		while IFS= read -r widevinecdm_version_path
		do
			if [ -n "${widevinecdm_version_path}" ];then
				echo ${widevinecdm_version_path}
				echo ${SUDO_EXECUTOR} chown -R root:root ${widevinecdm_version_path}
				${SUDO_EXECUTOR} chown -R root:root ${widevinecdm_version_path}
			fi
		done < <(printf '%s\n' "$WIDEVINECDM_VERSION_PATHS")
}
FUNC=$(declare -f loop_func)

