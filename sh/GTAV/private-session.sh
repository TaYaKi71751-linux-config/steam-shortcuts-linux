#!/bin/bash

# https://github.com/ValveSoftware/SteamOS/issues/1039
function check_kdialog(){
	export KDIALOG_USABLE=$(find / -name 'kdialog' -type f -exec {} --help \;)
	export KDIALOG_USABLE="$(echo $KDIALOG_USABLE | grep Usage)"
}

function check_zenity(){
	export ZENITY_USABLE=`find / -name 'zenity' -type f -exec {} --help \;`
	export ZENITY_USABLE="$(echo $ZENITY_USABLE | grep Usage)"
	env | grep STEAM_DECK\= && unset $ZENITY_USABLE
}

check_kdialog
check_zenity

function get_password(){
	if [ -n "${KDIALOG_USABLE}" ];then
		find / -name 'kdialog' -type f -exec bash -c "{} --password 'Enter Password' && pkill find " \;
	elif [ -n "${ZENITY_USABLE}" ];then
		find / -name 'zenity' -type f -exec bash -c "{} --password && pkill find"
	fi
}


function check_sudo() {
	if ( `sudo -nv` );then
		return "0"
	fi
	export SUDO_PASSWORD=$(get_password)
	# https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh…
	if ( echo ${SUDO_PASSWORD} | sudo -S echo A | grep A );then
		export SUDO_PASSWORD=${SUDO_PASSWORD}
	else
		check_sudo
	fi
}
check_sudo

# https://superuser.com/questions/553932/how-to-check-if-i-have-sudo-access
function sudo_executor(){
	if ( `sudo -nv` );then
		sudo $@
	else
		echo ${SUDO_PASSWORD} | sudo -S $@
	fi
}

#TODO TEST with Windows thing

# https://www.youtube.com/watch?v=OFd2af8wINE
# https://gall.dcinside.com/mgallery/board/view/?id=rdr2&no=135261
# https://github.com/Raitou/GTA-V-Public-Solo-Friend-Session
STARTUP_META_CONFIG_XML='<?xml version="1.0" encoding="UTF-8"?>
<CDataFileMgr__ContentsOfDataFileXml>
 <disabledFiles />
 <includedXmlFiles itemType="CDataFileMgr__DataFileArray" />
 <includedDataFiles />
 <dataFiles itemType="CDataFileMgr__DataFile">
  <Item>
   <filename>platform:/data/cdimages/scaleform_platform_pc.rpf</filename>
   <fileType>RPF_FILE</fileType>
  </Item>
  <Item>
   <filename>platform:/data/cdimages/scaleform_frontend.rpf</filename>
   <fileType>RPF_FILE_PRE_INSTALL</fileType>
  </Item>
 </dataFiles>
 <contentChangeSets itemType="CDataFileMgr__ContentChangeSet" />
 <patchFiles />
</CDataFileMgr__ContentsOfDataFileXml>'

function process_kill(){
	sudo_executor pkill GTA5.exe || true
	sudo_executor pkill PlayGTAV.exe || true
}
process_kill

GTAV_PATHS="$(find / 2> /dev/null | grep PlayGTAV.exe)"

echo ${GTAV_PATHS}
while IFS= read -r PLAY_GTAV_PATH
do
	GTAV_PATH=`dirname "${PLAY_GTAV_PATH}"`
	STARTUP_META_PATH="${GTAV_PATH}/x64/data/startup.meta"
	if [ -d "$(dirname '${STARTUP_META_PATH}')" ];then
		if [ -f "${STARTUP_META_PATH}" ];then
			rm "${STARTUP_META_PATH}"
		fi
	else
		continue
	fi
	# https://unix.stackexchange.com/questions/9784/how-can-i-read-line-by-line-from-a-variable-in-bash
	while IFS= read -r line
	do
		echo -en "$line\r" >> "${STARTUP_META_PATH}"
	done < <(printf '%s\n' "$STARTUP_META_CONFIG_XML")

# https://gall.dcinside.com/mgallery/board/view/?id=rdr2&no=135261
# https://gall.dcinside.com/mgallery/board/view/?id=rdr2&no=179677
	if [ "${GTA_SESSION_PW}" == "" ];then
		continue
	else
		echo -en "<!-- ${GTA_SESSION_PW} -->\r\n" >> "${STARTUP_META_PATH}"
	fi
	echo "${line}"
done < <(printf '%s\n' "${GTAV_PATHS}")

