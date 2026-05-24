#!/bin/bash

ORIG_HOME="${ORIG_HOME:-${HOME}}"

function source_shell_run_commands() {
	SHELL_RUN_COMMANDS="$(find "${ORIG_HOME}" -maxdepth 1 -name '.*shrc' 2> /dev/null || true)"
	for shrc in ${SHELL_RUN_COMMANDS[@]}; do
		echo "source ${shrc}"
		source "${shrc}"
	done
}

function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}

source_shell_run_commands
auto_path nordvpn-gui
auto_path nordvpn
auto_path gtk-launch
auto_path gio
auto_path dex
auto_path xdg-open
auto_path kdialog
auto_path zenity

if which nordvpn-gui > /dev/null 2>&1; then
	nordvpn-gui &
	exit 0
fi

show_error 'NordVPN GUI not found. Please run the NordVPN install shortcut first.'
exit 1
