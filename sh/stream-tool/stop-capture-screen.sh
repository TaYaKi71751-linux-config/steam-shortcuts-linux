#!/bin/bash

CONTAINER_BIN="podman"

sudo usermod -aG docker $USER

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
