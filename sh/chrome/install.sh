#!/bin/bash

function user_install_flatpak_package(){
	PACKAGE_NAME="$1"
RESULT="$(bash << EOF
flatpak install --user ${PACKAGE_NAME} --assumeyes
EOF
)"
if ( echo ${RESULT} | grep already\ installed );then
	echo A
	return
elif ( echo ${RESULT} | grep ${PACKAGE_NAME} | grep Similar );then
	PACKAGE_LINES="$(echo "${RESULT}" | grep "${PACKAGE_NAME}/")"
while IFS= read -r line
do
bash << EOF
	flatpak install --user $(echo $line | rev | cut -d ' ' -f1 | rev) --assumeyes
EOF
done < <(printf '%s\n' "$PACKAGE_LINES")
fi

}

function system_install_flatpak_package(){
	PACKAGE_NAME="$1"
RESULT="$(bash << EOF
flatpak install --system ${PACKAGE_NAME} --assumeyes
EOF
)"
if ( echo ${RESULT} | grep already\ installed );then
	echo A
	return
elif ( echo ${RESULT} | grep ${PACKAGE_NAME} | grep Similar );then
	PACKAGE_LINES="$(echo "${RESULT}" | grep "${PACKAGE_NAME}/")"
while IFS= read -r line
do
bash << EOF
	flatpak install --system $(echo $line | rev | cut -d ' ' -f1 | rev) --assumeyes
EOF
done < <(printf '%s\n' "$PACKAGE_LINES")
fi

	}

function set_default_browser(){
	DESKTOP_ID="com.microsoft.Edge.desktop"

	if ( command -v xdg-settings >/dev/null 2>&1 );then
		xdg-settings set default-web-browser "${DESKTOP_ID}" || true
	fi

	if ( command -v xdg-mime >/dev/null 2>&1 );then
		xdg-mime default "${DESKTOP_ID}" text/html || true
		xdg-mime default "${DESKTOP_ID}" x-scheme-handler/http || true
		xdg-mime default "${DESKTOP_ID}" x-scheme-handler/https || true
	fi

	echo "Set default browser to ${DESKTOP_ID}"
}

system_install_flatpak_package com.microsoft.Edge
user_install_flatpak_package com.microsoft.Edge
set_default_browser
