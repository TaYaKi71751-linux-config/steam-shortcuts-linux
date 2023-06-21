#!/bin/bash

CONTAINER_BIN="podman"

CONTAINER_BIN_PATH=`which ${CONTAINER_BIN}`
GST_DEPENDENCIES_PKG_NAMES=(\
	"gst-plugins-good" \
	"gst-plugins-bad" \
	"gst-plugins-ugly" \
	"gstreamer-vaapi" \
	"gst-plugin-pipewire" \
)

if [ -n "${CONTAINER_BIN_PATH}" ];then
	sudo pacman -Sy \
		podman \
		--noconfirm
fi

for gst_pkg in ${GST_DEPENDENCIES_PKG_NAMES[@]};do
	PKG_EXISTS=`sudo pacman -Q ${gst_pkg}`
	if [ "${PKG_EXISTS}" ];then
		echo "Package ${gst_pkg} is already installed, Skipping install"
		continue
	else
		echo "Package ${gst_pkg} is not installed, Installing ${gst_pkg}"
		sudo pacman -Sy ${gst_pkg} --noconfirm
	fi
done

#source ./sh/${CONTAINER_BIN}/enable.sh
source ./sh/stream-tool/stop-capture-screen.sh

sudo groupadd ${CONTAINER_BIN}
sudo usermod -aG ${CONTAINER_BIN} $USER
sudo ${CONTAINER_BIN} pull docker.io/alfg/nginx-rtmp
sudo ${CONTAINER_BIN} run -d -p 1935:1935 alfg/nginx-rtmp # https://linderud.dev/blog/streaming-the-steam-deck-to-obs/

SOURCE=""
if [ "${XDG_SESSION_TYPE}" == "x11" ];then
	SOURCE="ximagesrc"
else
	SOURCE="pipewiresrc"
fi
nohup \
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
				! rtmpsink location='rtmp://localhost/stream/gstreamer live=1' \
				>/dev/null 2>&1 \
&
while [ true ];do
nohup sudo ffmpeg -f kmsgrab -i - -vaapi_device /dev/dri/renderD128 \
-vf hwmap=derive_device=vaapi,scale_vaapi=format=nv12 -c:v h264_vaapi -bf 1 \
-f flv rtmp://localhost/stream/ffmpeg \
>/dev/null 2>&1
done
