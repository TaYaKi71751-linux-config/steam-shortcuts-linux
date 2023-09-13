#!/bin/bash

SHELL_RUN_COMMANDS=`find ~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	source ${shrc}
done

function enable_solo_lobby(){

source ./disable-solo-lobby.sh
disable_solo_lobby

session_ports=("6672" "61455" "61456" "61457" "61458")
ports=("--sport" "--dport")
targets=("INPUT" "OUTPUT")

RULE_HANDLE="-A"
PROTOCOL="-p udp"
REJECT="-j REJECT"

	for target in ${targets[@]};do
		for session_port in ${session_ports[@]};do
			for port in ${ports[@]};do
				echo "iptables ${RULE_HANDLE} ${target} ${PROTOCOL} ${port} ${session_port} ${REJECT}"
				sudo iptables ${RULE_HANDLE} ${target} ${PROTOCOL} ${port} ${session_port} ${REJECT}
			done
		done
	done
}

enable_solo_lobby
