#!/bin/bash

CONTAINER_BIN="docker"
CONTAINERD_BIN="dockerd"

function run_daemon(){
	IS_CONTAINERD_RUNNING=`ps -A | grep ${CONTAINERD_BIN}`
	if [ -n "${IS_CONTAINERD_RUNNING}" ];then
		echo ${CONTAINERD_BIN} already running
	else
		Running ${CONTAINERD_BIN} with systemd-run
		sudo systemd-run ${CONTAINERD_BIN}
		run_daemon
	fi
}

run_daemon

sudo usermod -aG ${CONTAINER_BIN} $USER

sudo ${CONTAINER_BIN} pull docker.io/alfg/nginx-rtmp

containers=`sudo ${CONTAINER_BIN} ps -aq --filter ancestor=docker.io/alfg/nginx-rtmp`
for container in ${containers[@]};do
	sudo ${CONTAINER_BIN} stop $container
	sudo ${CONTAINER_BIN} rm $container
done

gstreamer_pids=`cat /tmp/screen-copy-gstreamer.pid`
if [ -n "${gstreamer_pids}" ];then
	for pid in ${gstreamer_pids[@]};do
		sudo kill "${pid}"
	done
	echo "" > /tmp/screen-copy-gstreamer.pid
fi
ffmpeg_pids=`cat /tmp/screen-copy-ffmpeg.pid`
if [ -n "${ffmpeg_pids}" ];then
	for pid in ${ffmpeg_pids[@]};do
		sudo kill "${pid}"
	done
	echo "" > /tmp/screen-copy-ffmpeg.pid
fi
