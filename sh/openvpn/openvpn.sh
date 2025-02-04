#!/bin/bash
# exec 2>&1
# exec > >(tee file.log)

SHELL_RUN_COMMANDS=`find ${ORIG_HOME} -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}
auto_path openvpn
auto_path node
auto_path kdialog
auto_path zenity

ORIG_HOME=${HOME}

function check_openvpn(){
	export OPENVPN_USABLE=`find / -name 'openvpn' -type f -exec {} --help \;`
	if ( which openvpn );then
		export OPENVPN_USABLE="true"
	else
		unset OPENVPN_USABLE
	fi
}
check_openvpn

# https://github.com/ValveSoftware/SteamOS/issues/1039
function check_kdialog(){
	if ( which kdialog );then
		export KDIALOG_USABLE="true"
	else
		unset KDIALOG_USABLE
	fi
}

function check_zenity(){
	if ( which zenity );then
		export ZENITY_USABLE="true"
	else
		unset ZENITY_USABLE="true"
	fi
	env | grep STEAM_DECK\= && unset $ZENITY_USABLE
}
check_kdialog
check_zenity

if [ -z "${OPENVPN_USABLE}" ];then
	if [ -n "${KDIALOG_USABLE}" ];then
		kdialog --error 'openvpn binary not found. please install openvpn.'
	elif [ -n "${ZENITY_USABLE}" ];then
		zenity --error --text='openvpn binary not found. please install openvpn.'
	fi
fi

if [ -z "${OPENVPN_CONFIG_PATH}" ];then
	if [ -n "${KDIALOG_USABLE}" ];then
		kdialog --error 'openvpn config not found. please select openvpn config.'
	elif [ -n "${ZENITY_USABLE}" ];then
		zenity --error --text='openvpn config not found. please select openvpn config.'
	fi
fi

function get_password(){
	if [ -n "${KDIALOG_USABLE}" ];then
		kdialog --password 'Enter Password'
	elif [ -n "${ZENITY_USABLE}" ];then
		zenity --password
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
sudo_executor mkdir -p /etc/openvpn
sudo_executor bash << EOF
echo '#!/bin/bash' > /etc/openvpn/update-resolv-conf

echo 'case "\$script_type" in' >> /etc/openvpn/update-resolv-conf
echo '  --up)' >> /etc/openvpn/update-resolv-conf
    # Set DNS servers
echo '    sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4' >> /etc/openvpn/update-resolv-conf
echo '    ;;' >> /etc/openvpn/update-resolv-conf
echo '  --down)' >> /etc/openvpn/update-resolv-conf
    # Clear DNS servers
echo 'esac' >> /etc/openvpn/update-resolv-conf
chmod +x /etc/openvpn/update-resolv-conf
EOF
TARGET_CIPHER="$(cat "${OPENVPN_CONFIG_PATH}" | grep "^cipher" | rev | cut -d ' ' -f1 | rev | tr -d ' ' | tr -d '\r' | tr -d '\n')"
function run_openvpn(){
		sudo_executor openvpn \
			--data-ciphers ${TARGET_CIPHER} \
			--data-ciphers-fallback ${TARGET_CIPHER} \
			--config "${OPENVPN_CONFIG_PATH}"
}
echo $TARGET_CIPHER

sudo_executor sysctl -w net.ipv6.conf.all.disable_ipv6=1
# https://www.reddit.com/r/PrivateInternetAccess/comments/j1iyl7/openvpn_client_no_longer_connects_cipher_not/?rdt=54856
run_openvpn
