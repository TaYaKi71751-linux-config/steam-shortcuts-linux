#!/bin/bash

sudo usermod -aG docker $USER

containers=`sudo docker ps -aq --filter ancestor=alfg/nginx-rtmp`
for container in ${containers[@]};do
	sudo docker stop $container
	sudo docker rm $container
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
