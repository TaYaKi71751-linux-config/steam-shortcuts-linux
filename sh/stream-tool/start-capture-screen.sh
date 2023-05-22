#!/bin/bash

source ./sh/docker/enable.sh
source ./sh/stream-tool/stop-capture-screen.sh

sudo usermod -aG docker $USER
docker run -d -p 1935:1935 alfg/nginx-rtmp # https://linderud.dev/blog/streaming-the-steam-deck-to-obs/


sudo ffmpeg -f kmsgrab -i - -vaapi_device /dev/dri/renderD128 \
-vf hwmap=derive_device=vaapi,scale_vaapi=format=nv12 -c:v h264_vaapi -bf 1 \
-f flv rtmp://localhost/stream/deck & echo $! >> /tmp/ffmpeg-rtmp-copy.pid # https://serverfault.com/questions/205498/how-to-get-pid-of-just-started-process
