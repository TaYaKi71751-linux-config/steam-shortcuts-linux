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
   <filename>platform:/data/ui/value_conversion.rpf</filename>
   <fileType>RPF_FILE</fileType>
  </Item>
  <Item>
   <filename>platform:/data/ui/widgets.rpf</filename>
   <fileType>RPF_FILE</fileType>
  </Item>
  <Item>
   <filename>platform:/textures/ui/ui_photo_stickers.rpf</filename>
   <fileType>RPF_FILE</fileType>
  </Item>
  <Item>
   <filename>platform:/textures/ui/ui_platform.rpf</filename>
   <fileType>RPF_FILE</fileType>
  </Item>
  <Item>
   <filename>platform:/data/ui/stylesCatalog</filename>
   <fileType>aWeaponizeDisputants</fileType> <!-- collision -->
  </Item>
  <Item>
   <filename>platform:/data/cdimages/scaleform_frontend.rpf</filename>
   <fileType>RPF_FILE_PRE_INSTALL</fileType>
  </Item>
  <Item>
   <filename>platform:/textures/ui/ui_startup_textures.rpf</filename>
   <fileType>RPF_FILE</fileType>
  </Item>
  <Item>
   <filename>platform:/data/ui/startup_data.rpf</filename>
   <fileType>RPF_FILE</fileType>
  </Item>
  <Item>
    <filename>platform:/boot_launcher_flow.#mt</filename>
    <fileType>STREAMING_FILE</fileType>
    <registerAs>boot_flow/boot_launcher_flow</registerAs>
    <overlay value="false" />
    <patchFile value="false" />
  </Item>
 </dataFiles>
 <contentChangeSets itemType="CDataFileMgr__ContentChangeSet" />
 <patchFiles />
</CDataFileMgr__ContentsOfDataFileXml>'

# https://gall.dcinside.com/mgallery/board/view/?id=rdr2&no=135261
BOOT_LAUNCHER_FLOW_CONFIG_XML='<?xml version="1.0" encoding="UTF-8"?>
<rage__fwuiFlowBlock>
 <ID>boot_flow</ID>
 <EntryPoints>
  <Item>
   <ID>default_entry</ID>
   <Target>boot_screen_host.account_picker_activity_sentinel.account_picker_wrapper</Target>
  </Item>
  <Item>
   <ID>bye</ID>
   <Target>boot_screen_host.legal_screen_activity_sentinel.stinger</Target>
  </Item>
  <Item>
   <ID>sign_out</ID>
   <Target>boot_screen_host.account_picker_activity_sentinel.account_picker_wrapper</Target>
  </Item>
 </EntryPoints>
 <ExitPoints>
  <Item>
   <ID>exit</ID>
  </Item>
 </ExitPoints>
 <FlowRoot>
  <ID>input_context_switch</ID>
  <State type="StateSetInputContext">
   <ContextType>BOOT_FLOW</ContextType>
  </State>
  <Children>
   <Item>
    <ID>boot_screen_host</ID>
    <State type="StateUIObjectStreamedSceneHost">
     <SceneName>boot_flow/boot_screen_host</SceneName>
     <GCOnRemove value="True" />
    </State>
    <Children>
     <Item>
      <ID>account_picker_activity_sentinel</ID>
      <State type="rage__StateActivitySentinel">
       <ActivityID>account_picker</ActivityID>
      </State>
      <Children>
       <Item>
        <ID>account_picker_wrapper</ID>
        <State type="StateAccountPicker" />
        <LinkMap>
         <Item key="next">
          <Target>account_picker</Target>
         </Item>
         <Item key="failed">
          <Target>^.^.profile_flow_activity_sentinel.wait_for_profile</Target>
         </Item>
         <Item key="profile_changed">
          <Target>^.^.profile_flow_activity_sentinel.wait_for_profile</Target>
         </Item>
         <Item key="profile_unchanged">
          <Target>^.^.profile_flow_activity_sentinel.wait_for_profile</Target>
         </Item>
        </LinkMap>
        <Children>
         <Item>
          <ID>account_picker</ID>
          <State type="StateUIObjectStreamedSceneHost">
           <SceneName>boot_flow/account_picker/account_picker_with_background</SceneName>
           <ParentPath>boot_screen_host.PAN_Content</ParentPath>
           <EnterAnimation>boot_screen_fade_in</EnterAnimation>
           <ExitAnimation>boot_screen_fade_out</ExitAnimation>
          </State>
         </Item>
        </Children>
       </Item>
      </Children>
     </Item>
     <Item>
      <ID>legal_screen_activity_sentinel</ID>
      <State type="rage__StateActivitySentinel">
       <ActivityID>legal_screen</ActivityID>
      </State>
      <Children>
       <Item>
        <ID>stinger</ID>
        <State type="StateUIObjectStreamedSceneHost">
         <SceneName>boot_flow/legal_splash/stinger</SceneName>
         <ParentPath>boot_screen_host.PAN_Content</ParentPath>
        </State>
        <LinkMap>
         <Item key="to_legal">
          <Target>^.stinger</Target>
         </Item>
        </LinkMap>
       </Item>
       <Item>
        <ID>legal_screen</ID>
        <State type="StateUIObjectStreamedSceneHost">
         <SceneName>boot_flow/legal_splash/legal_splash</SceneName>
         <EnterAnimation>legal_splash_animation</EnterAnimation>
         <ParentPath>boot_screen_host.PAN_Content</ParentPath>
        </State>
        <LinkMap>
         <Item key="next">
          <Target>^.^.profile_flow_activity_sentinel.wait_for_profile</Target>
         </Item>
        </LinkMap>
       </Item>
      </Children>
     </Item>
     <Item>
      <ID>profile_flow_activity_sentinel</ID>
      <State type="rage__StateActivitySentinel">
       <ActivityID>profile_flow</ActivityID>
      </State>
      <Children>
       <Item>
        <ID>wait_for_profile</ID>
        <State type="StateWaitForProfileLoad" />
        <LinkMap>
         <Item key="next">
          <Target>^.language_screen_wrapper</Target>
         </Item>
         <Item key="exit">
          <Target>exit</Target>
          <LinkInfo>LINK_TO_EXTERNAL</LinkInfo>
         </Item>
         <Item key="yes">
          <Target>exit</Target>
          <LinkInfo>LINK_TO_EXTERNAL</LinkInfo>
         </Item>
        </LinkMap>
       </Item>
       <Item>
        <ID>language_screen_wrapper</ID>
        <State type="StateLanguageSelect" />
        <LinkMap>
         <Item key="next">
          <Target>language_screen</Target>
         </Item>
         <Item key="failed"platform="x64|orbis">
          <Target>^.hdr_enabled_screen_wrapper</Target>
         </Item>
        </LinkMap>
        <Children>
         <Item>
          <ID>language_screen</ID>
          <State type="StateUIObjectStreamedSceneHost">
           <SceneName>boot_flow/language_selection</SceneName>
           <ParentPath>boot_screen_host.PAN_Content</ParentPath>
          </State>
          <LinkMap>
           <Item key="to_next_screen"platform="x64|orbis">
            <Target>^.^.hdr_enabled_screen_wrapper</Target>
           </Item>
          </LinkMap>
         </Item>
        </Children>
       </Item>
       <Item>
        <ID>hdr_enabled_screen_wrapper</ID>
        <State type="StateStartupSettingSelection">
         <SettingPath>
          <pathElements>
           <Item>display</Item>
           <Item>hdr</Item>
          </pathElements>
         </SettingPath>
        </State>
        <LinkMap>
         <Item key="next">
          <Target>hdr_enabled_screen</Target>
         </Item>
         <Item key="failed">
          <Target>^.brightness_screen_wrapper</Target>
         </Item>
        </LinkMap>
        <Children>
         <Item>
          <ID>hdr_enabled_screen</ID>
          <State type="StateUIObjectStreamedSceneHost">
           <SceneName>boot_flow/hdr_enabled_screen</SceneName>
           <ParentPath>boot_screen_host.PAN_Content</ParentPath>
          </State>
          <LinkMap>
           <Item key="to_next_screen">
            <Target>^.^.brightness_screen_wrapper</Target>
           </Item>
          </LinkMap>
         </Item>
        </Children>
       </Item>
       <Item>
        <ID>brightness_screen_wrapper</ID>
        <State type="StateGammaCalibration">
         <MovieFilename>PAUSE_MENU_CALIBRATION</MovieFilename>
        </State>
        <LinkMap>
         <Item key="next">
          <Target>brightness_screen</Target>
         </Item>
         <Item key="failed">
          <Target>^.hdr_screen_wrapper</Target>
         </Item>
        </LinkMap>
        <Children>
         <Item>
          <ID>brightness_screen</ID>
          <State type="StateUIObjectStreamedSceneHost">
           <SceneName>boot_flow/brightness_calibration</SceneName>
           <ParentPath>boot_screen_host.PAN_Content</ParentPath>
          </State>
          <LinkMap>
           <Item key="to_next_screen">
            <Target>^.^.hdr_screen_wrapper</Target>
           </Item>
          </LinkMap>
         </Item>
        </Children>
       </Item>
       <Item>
        <ID>hdr_screen_wrapper</ID>
        <State type="StateHDRCalibration">
         <MovieFilename>UIOBJECT_SCENE_GENERIC</MovieFilename>
        </State>
        <LinkMap>
         <Item key="next">
          <Target>hdr_screen</Target>
         </Item>
         <Item key="failed">
          <Target>^.subtitles_screen_wrapper</Target>
         </Item>
        </LinkMap>
        <Children>
         <Item>
          <ID>hdr_screen</ID>
          <State type="StateUIObjectStreamedSceneHost">
           <SceneName>boot_flow/hdr</SceneName>
           <ParentPath>boot_screen_host.PAN_Content</ParentPath>
          </State>
          <LinkMap>
           <Item key="to_next_screen">
            <Target>^.^.subtitles_screen_wrapper</Target>
           </Item>
          </LinkMap>
         </Item>
        </Children>
       </Item>
       <Item>
        <ID>subtitles_screen_wrapper</ID>
        <State type="StateSubtitlesSelect">
         <SettingPath>
          <pathElements>
           <Item>display</Item>
           <Item>hud</Item>
           <Item>subtitles</Item>
          </pathElements>
         </SettingPath>
        </State>
        <LinkMap>
         <Item key="next">
          <Target>subtitles_screen</Target>
         </Item>
         <Item key="failed">
          <Target>^.audio_screen_wrapper</Target>
         </Item>
        </LinkMap>
        <Children>
         <Item>
          <ID>subtitles_screen</ID>
          <State type="StateUIObjectStreamedSceneHost">
           <SceneName>boot_flow/subtitles_selection</SceneName>
           <ParentPath>boot_screen_host.PAN_Content</ParentPath>
          </State>
          <LinkMap>
           <Item key="to_next_screen">
            <Target>^.^.audio_screen_wrapper</Target>
           </Item>
          </LinkMap>
         </Item>
        </Children>
       </Item>
       <Item>
        <ID>audio_screen_wrapper</ID>
        <State type="StateStartupSettingSelection">
         <SettingPath>
          <pathElements>
           <Item>audio</Item>
           <Item>speakerOutput</Item>
          </pathElements>
         </SettingPath>
        </State>
        <LinkMap>
         <Item key="next">
          <Target>audio_screen</Target>
         </Item>
         <Item key="failed">
          <Target>exit</Target>
          <LinkInfo>LINK_TO_EXTERNAL</LinkInfo>
         </Item>
        </LinkMap>
        <Children>
         <Item>
          <ID>audio_screen</ID>
          <State type="StateUIObjectStreamedSceneHost">
           <SceneName>boot_flow/audio_selection</SceneName>
           <ParentPath>boot_screen_host.PAN_Content</ParentPath>
          </State>
          <LinkMap>
           <Item key="to_next_screen">
            <Target>exit</Target>
            <LinkInfo>LINK_TO_EXTERNAL</LinkInfo>
           </Item>
          </LinkMap>
         </Item>
        </Children>
       </Item>
      </Children>
     </Item>
    </Children>
   </Item>
  </Children>
 </FlowRoot>
</rage__fwuiFlowBlock>'

function process_kill() {
	sudo_executor pkill RDR2.exe || true
	sudo_executor pkill PlayRDR2.exe || true
}
process_kill

RDR2_PATHS="$(find / 2> /dev/null | grep PlayRDR2.exe)"

echo ${RDR2_PATHS}
while IFS= read -r PLAY_RDR2_PATH
do
	RDR2_PATH=`dirname "${PLAY_RDR2_PATH}"`
	STARTUP_META_PATH="${RDR2_PATH}/x64/data/startup.meta"
	BOOT_LAUNCHER_FLOW_PATH="${RDR2_PATH}/x64/boot_launcher_flow.ymt"
	if [ -d "$(dirname '${STARTUP_META_PATH}')" ];then
		if [ -f "${STARTUP_META_PATH}" ];then
			rm "${STARTUP_META_PATH}"
		fi
	else
		continue
	fi
	if [ -d "$(dirname '${BOOT_LAUNCHER_FLOW_PATH}')" ];then
		if [ -f "${BOOT_LAUNCHER_FLOW_PATH}" ];then
			rm "${BOOT_LAUNCHER_FLOW_PATH}"
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
	while IFS= read -r line
	do
		echo -en "$line\r" >> "${BOOT_LAUNCHER_FLOW_PATH}"
	done < <(printf '%s\n' "$BOOT_LAUNCHER_FLOW_CONFIG_XML")

	if [ "${RDO_PW}" == "" ];then
		continue
	else
		echo -en "<!-- ${RDO_PW} -->\r\n" >> "${STARTUP_META_PATH}"
	fi
	echo "${line}"
done < <(printf '%s\n' "${RDR2_PATHS}")

