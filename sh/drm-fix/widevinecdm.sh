#!/bin/bash

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo pkexec)"

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

# https://www.reddit.com/r/SteamDeck/comments/1409qdt/crunchyroll_getting_shak6002generic_on_steam_deck/
${SUDO_EXECUTOR} find ${ORIG_HOME} -type d -name 'WidevineCdm' -exec ${SUDO_EXECUTOR} bash -c " widevinecdm_path=\"{}\"; $FUNC; loop_func" \;

