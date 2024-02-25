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


#Discord
system_install_flatpak_package tv.kodi.Kodi
