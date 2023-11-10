#!/bin/bash

CONTAINER_BIN="docker"
CONTAINERD_BIN="dockerd"

function check_sudo() {
	if ( `sudo -nv` );then
		return "0"
	fi
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
export SUDO_EXECUTOR="$(sudo -nv && echo sudo || echo echo \${SUDO_PASSWORD} \| sudo -S)"

CONTAINER_BIN_PATH=`which ${CONTAINER_BIN}`
GST_DEPENDENCIES_PKG_NAMES=(\
	"gst-plugins-good" \
	"gst-plugins-bad" \
	"gst-plugins-ugly" \
	"gstreamer-vaapi" \
	"gst-plugin-pipewire" \
)

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

function install_packages(){
	if [ -n "${CONTAINER_BIN_PATH}" ];then
		${SUDO_EXECUTOR} pacman -Sy \
			${CONTAINER_BIN} \
			--noconfirm
	fi
	for gst_pkg in ${GST_DEPENDENCIES_PKG_NAMES[@]};do
		PKG_EXISTS=`${SUDO_EXECUTOR} pacman -Q ${gst_pkg}`
		if [ "${PKG_EXISTS}" ];then
			echo "Package ${gst_pkg} is already installed, Skipping install"
			continue
		else
			echo "Package ${gst_pkg} is not installed, Installing ${gst_pkg}"
			${SUDO_EXECUTOR} pacman -Sy ${gst_pkg} --noconfirm
		fi
	done
}

install_packages
run_daemon


#source ./sh/${CONTAINER_BIN}/enable.sh
echo ${PWD}
STOP_SCREEN_SHELL_PATH=`find ./ -name 'stop-capture-screen.sh'`
STOP_SCREEN_OUT_PATH=`find ./ -name 'stop-capture-screen.out'`
if [ -n "${STOP_SCREEN_SHELL_PATH}" ];then
	for sh_path in ${STOP_SCREEN_SHELL_PATH[@]};do
		echo "Running ${sh_path}"
		source ${sh_path}
		echo "Exited ${sh_path}"
	done
else
	echo "Cannot find 'stop-capture-screen.sh' in path '${PWD}'"
	if [ -n "${STOP_SCREEN_OUT_PATH}" ];then
		for out_path in ${STOP_SCREEN_OUT_PATH[@]};do
			echo "Running ${out_path}"
			bash -c "${out_path}"
			echo "Exited ${out_path}"
		done
	else
		echo "Cannot find 'stop-capture-screen.{sh,out}' in path '${PWD}' aborting"
		exit -1
	fi
fi

${SUDO_EXECUTOR} groupadd ${CONTAINER_BIN}
${SUDO_EXECUTOR} usermod -aG ${CONTAINER_BIN} $USER
${SUDO_EXECUTOR} ${CONTAINER_BIN} pull docker.io/alfg/nginx-rtmp
${SUDO_EXECUTOR} ${CONTAINER_BIN} run -d -p 1935:1935 docker.io/alfg/nginx-rtmp # https://linderud.dev/blog/streaming-the-steam-deck-to-obs/

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
${SUDO_EXECUTOR} ffmpeg -f kmsgrab -i - -vaapi_device /dev/dri/renderD128 \
-vf hwmap=derive_device=vaapi,scale_vaapi=format=nv12 -c:v h264_vaapi -bf 1 \
-f flv rtmp://localhost/stream/ffmpeg \
>/dev/null 2>&1
done
