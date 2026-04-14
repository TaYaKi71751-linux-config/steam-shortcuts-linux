#!/bin/bash

podman ps -aq --filter ancestor=docker.io/alfg/nginx-rtmp
containers=`podman ps -aq --filter ancestor=docker.io/alfg/nginx-rtmp`
for container in ${containers[@]};do
	podman stop $container
	podman rm $container
done

podman run -i --rm \
    -p 1935:1935 \
    docker.io/alfg/nginx-rtmp