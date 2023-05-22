#!/bin/bash

sudo usermod -aG docker $USER

containers=`docker ps -aq --filter ancestor=alfg/nginx-rtmp`
for container in ${containers[@]};do
	docker stop $container
	docker rm $container
done

pids=`cat /tmp/ffmpeg-rtmp-copy.pid`
if [ -n "${pid}" ];then
	for pid in ${pids[@]};do
		sudo kill "${pid}"
	done
	echo "" > /tmp/ffmpeg-rtmp-copy.pid
fi
