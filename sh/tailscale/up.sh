#!/bin/bash

ORIG_HOME=${HOME}
SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

function get_password(){
	if ( which kdialog );then
		kdialog --password 'Enter password'
	elif ( which zenity );then
		zenity --password
	fi
}


function check_sudo() {
	if ( `sudo -nv` );then
		return "0"
	fi
	export SUDO_PASSWORD=$(get_password)
	# https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh…
	if ( echo ${SUDO_PASSWORD} | sudo -S echo A | grep A );then
		export SUDO_PASSWORD=${SUDO_PASSWORD}
	else
		check_sudo
	fi
}
check_sudo


function auto_path() {
	TARGET_PATHS="$(find $HOME -name "$1" -type f 2>/dev/null)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}
auto_path tailscaled
auto_path tailscale

which tailscaled || exit -1
which tailscale || exit -1

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
function sudo_executor(){
	if ( `sudo -nv` );then
		sudo $@
	else
		echo ${SUDO_PASSWORD} | sudo -S $@
	fi
}

function open_login_url(){
	TAILSCALE_LOGIN_URL="$1"
	if [ -n "${TAILSCALE_LOGIN_URL}" ];then
		# if ( command -v steam >/dev/null 2>&1 );then
		# 	steam "steam://openurl/${TAILSCALE_LOGIN_URL}" || true
		# elif ( command -v flatpak >/dev/null 2>&1 );then
		# 	flatpak run org.mozilla.firefox "${TAILSCALE_LOGIN_URL}" || xdg-open "${TAILSCALE_LOGIN_URL}" || true
		# else
			xdg-open "${TAILSCALE_LOGIN_URL}" || true
		# fi
	fi
}

function extract_login_url(){
	grep -Eom1 'https?://[^[:space:]]+' "$1" || true
}

TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --reset "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --exit-node=${TAILSCALE_EXIT_NODE} "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --ssh "
TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --operator=${HOSTNAME} "
if [ -n "${TAILSCALE_EXIT_NODE}" ];then
	TAILSCALE_OPTIONS="${TAILSCALE_OPTIONS} --exit-node-allow-lan-access "
fi

function up(){
	DAEMON_STATUS=`ps -A | grep tailscaled || true`
	if [ -n "${DAEMON_STATUS}" ];then
		echo "tailscaled already running"
		echo ${TAILSCALE_OPTIONS}
		while IFS= read -r line
		do
			TAILSCALE_OUTPUT_FILE="$(mktemp)"
			sudo_executor "$line" up ${TAILSCALE_OPTIONS} > "${TAILSCALE_OUTPUT_FILE}" 2>&1 &
			TAILSCALE_UP_PID=$!
			TAILSCALE_LOGIN_URL=""
			TAILSCALE_LOGIN_URL_OPENED=""
			while kill -0 "${TAILSCALE_UP_PID}" >/dev/null 2>&1;do
				TAILSCALE_LOGIN_URL="$(extract_login_url "${TAILSCALE_OUTPUT_FILE}")"
				if [ -n "${TAILSCALE_LOGIN_URL}" ] && [ -z "${TAILSCALE_LOGIN_URL_OPENED}" ];then
					cat "${TAILSCALE_OUTPUT_FILE}"
					open_login_url "${TAILSCALE_LOGIN_URL}"
					TAILSCALE_LOGIN_URL_OPENED="1"
				fi
				sleep 1
			done
			wait "${TAILSCALE_UP_PID}"
			TAILSCALE_UP_STATUS=$?
			TAILSCALE_OUTPUT="$(cat "${TAILSCALE_OUTPUT_FILE}")"
			echo "${TAILSCALE_OUTPUT}"
			TAILSCALE_LOGIN_URL="$(extract_login_url "${TAILSCALE_OUTPUT_FILE}")"
			rm -f "${TAILSCALE_OUTPUT_FILE}"
			if [ -n "${TAILSCALE_LOGIN_URL}" ];then
				open_login_url "${TAILSCALE_LOGIN_URL}"
			fi
			return "${TAILSCALE_UP_STATUS}"
		done <<< "$(find $HOME -name 'tailscale' -type f 2>/dev/null)"
	else
		echo "tailscaled not running, run tailscaled"
		while IFS= read -r line
		do
			sudo_executor systemd-run "$line"
		done <<< "$(find $HOME -name 'tailscaled' -type f 2>/dev/null)"
		up
	fi
}
up
