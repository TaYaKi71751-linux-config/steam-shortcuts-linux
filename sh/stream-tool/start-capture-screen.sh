#!/bin/bash

source ./sh/docker/enable.sh
source ./sh/stream-tool/stop-capture-screen.sh

sudo usermod -aG docker $USER
docker run -d -p 1935:1935 alfg/nginx-rtmp # https://linderud.dev/blog/streaming-the-steam-deck-to-obs/

SOURCE=""
if [ "${XDG_SESSION_TYPE}" == "x11" ];then
	SOURCE="ximagesrc"
else
	SOURCE="pipewiresrc"
fi
gst-launch-1.0 -e \
    ${SOURCE} do-timestamp=True \
        ! queue \
        ! videoconvert \
        ! queue \
        ! vaapih264enc \
        ! h264parse \
								! mux. \
				pulsesrc device="$(pactl get-default-sink).monitor" \
        ! queue \
        ! fdkaacenc bitrate=256000 \
        ! mux. \
    flvmux name=mux streamable=True \
        ! rtmpsink location='rtmp://localhost/stream/gstreamer live=1' & echo $! >> /tmp/screen-copy-gstreamer.pid \ # https://serverfault.com/questions/205498/how-to-get-pid-of-just-started-process
&
while [ true ];do
sudo ffmpeg -f kmsgrab -i - -vaapi_device /dev/dri/renderD128 \
-vf hwmap=derive_device=vaapi,scale_vaapi=format=nv12 -c:v h264_vaapi -bf 1 \
-f flv rtmp://localhost/stream/ffmpeg & echo $! > /tmp/screen-copy-ffmpeg.pid # https://serverfault.com/questions/205498/how-to-get-pid-of-just-started-process
done
