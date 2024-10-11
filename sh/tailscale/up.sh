#!/bin/bash

SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

ORIG_HOME=${HOME}

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
	TARGET_PATHS="$(find $HOME -name "$1" -type f)"
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
			while IFS= read -r node_bin
			do
			sudo_executor "${node_bin}" << EOF
	const { execSync, spawn } = require('child_process');
	const check = spawn('${line}', ['up', '--reset', '--ssh']);
	let stdout = '';
	check.stderr.on('data', (data) => {
		stdout += data;
		if (stdout.includes('\\n\\n')) {
			console.log(stdout);
			try{execSync(\`zenity --info --text='\${stdout}'\`).toString();}catch(e){console.error(e);}
			try{execSync(\`kdialog --msgbox '\${stdout}'\`).toString();}catch(e){console.error(e);}
		}
	});
EOF
			done <<< "$(find $HOME -name 'node' -type f)"
			sudo_executor "$line" up ${TAILSCALE_OPTIONS}
		done <<< "$(find $HOME -name 'tailscale' -type f)"
	else
		echo "tailscaled not running, run tailscaled"
		while IFS= read -r line
		do
			sudo_executor systemd-run "$line"
		done <<< "$(find $HOME -name 'tailscaled' -type f)"
		up
	fi
}
up
