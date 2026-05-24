#!/bin/bash

set -e

ORIG_HOME="${ORIG_HOME:-${HOME}}"

function source_shell_run_commands() {
	SHELL_RUN_COMMANDS="$(find "${ORIG_HOME}" -maxdepth 1 -name '.*shrc' 2> /dev/null || true)"
	for shrc in ${SHELL_RUN_COMMANDS[@]}; do
		echo "source ${shrc}"
		source "${shrc}"
	done
}

yay -Sy nordvpn-bin --noconfirm
yay -Sy nordvpn-gui-bin --noconfirm
sudo usermod -aG nordvpn $USER
sudo systemctl enable --now nordvpnd.service
sudo reboot