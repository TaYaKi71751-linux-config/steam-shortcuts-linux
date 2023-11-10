#!/bin/bash

CONTAINER_BIN="docker"
CONTAINERD_BIN="dockerd"

function check_sudo() {
	sudo -nv && exit
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
SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo echo \${SUDO_PASSWORD} \| sudo -S)"

function run_daemon(){
	IS_CONTAINERD_RUNNING=`ps -A | grep ${CONTAINERD_BIN}`
	if [ -n "${IS_CONTAINERD_RUNNING}" ];then
		echo ${CONTAINERD_BIN} already running
	else
		Running ${CONTAINERD_BIN} with systemd-run
		${SUDO_EXECUTOR} systemd-run ${CONTAINERD_BIN}
		run_daemon
	fi
}

run_daemon

${SUDO_EXECUTOR} usermod -aG ${CONTAINER_BIN} $USER

${SUDO_EXECUTOR} ${CONTAINER_BIN} pull docker.io/alfg/nginx-rtmp

containers=`${SUDO_EXECUTOR} ${CONTAINER_BIN} ps -aq --filter ancestor=docker.io/alfg/nginx-rtmp`
for container in ${containers[@]};do
	${SUDO_EXECUTOR} ${CONTAINER_BIN} stop $container
	${SUDO_EXECUTOR} ${CONTAINER_BIN} rm $container
done

gstreamer_pids=`cat /tmp/screen-copy-gstreamer.pid`
if [ -n "${gstreamer_pids}" ];then
	for pid in ${gstreamer_pids[@]};do
		${SUDO_EXECUTOR} kill "${pid}"
	done
	echo "" > /tmp/screen-copy-gstreamer.pid
fi
ffmpeg_pids=`cat /tmp/screen-copy-ffmpeg.pid`
if [ -n "${ffmpeg_pids}" ];then
	for pid in ${ffmpeg_pids[@]};do
		${SUDO_EXECUTOR} kill "${pid}"
	done
	echo "" > /tmp/screen-copy-ffmpeg.pid
fi
