#!/bin/bash

__ORG_NAME__="TaYaKi71751-linux-config"
__REPO_NAME__="steam-shortcuts-linux"

touch ~/.bashrc

SHELL_RUN_COMMANDS=`find	~ -maxdepth 1 -name '.*shrc'`
for shrc in ${SHELL_RUN_COMMANDS[@]};do
	echo "source ${shrc}"
	source ${shrc}
done

ORIG_HOME=${HOME}

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

function install_flatpak_package(){
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

sudo_executor mkdir -p /var/lib/pacman/

sudo_executor frzr-unlock

sudo_executor steamos-readonly disable

ORIG_PACMAN_CONF="$(sudo_executor cat /etc/pacman.conf)"
if ( sudo_executor cat /etc/pacman.conf | grep "chaotic\-aur" );then
	echo Removing chaotic-aur from /etc/pacman.conf
	# https://stackoverflow.com/questions/25224994/how-to-bash-cat-or-tee-into-a-file-with-sudo-with-eof-and-with-silent-output
	RESULT_PACMAN_CONF="$(echo "${ORIG_PACMAN_CONF}" | sed 's/\[chaotic-aur\]//g')"
sudo_executor tee /etc/pacman.conf &> /dev/null <<EOF
${RESULT_PACMAN_CONF}
EOF
ORIG_PACMAN_CONF="$(sudo_executor cat /etc/pacman.conf)"	
	RESULT_PACMAN_CONF="$(echo "${RESULT_PACMAN_CONF}" | sed "s/Include[ ]*=[ ]*\/etc\/pacman.d\/chaotic-mirrorlist//g")"
sudo_executor tee /etc/pacman.conf &> /dev/null <<EOF
${RESULT_PACMAN_CONF}
EOF
fi

ORIG_PACMAN_CONF="$(sudo_executor cat /etc/pacman.conf)"
if ( sudo_executor cat /etc/pacman.conf | grep "holoiso\-next" );then
	echo Removing holoiso-next from /etc/pacman.conf
	# https://stackoverflow.com/questions/25224994/how-to-bash-cat-or-tee-into-a-file-with-sudo-with-eof-and-with-silent-output
	RESULT_PACMAN_CONF="$(echo "${ORIG_PACMAN_CONF}" | sed 's/\[holoiso-next\]//g')"
sudo_executor tee /etc/pacman.conf &> /dev/null <<EOF
${RESULT_PACMAN_CONF}
EOF
ORIG_PACMAN_CONF="$(sudo_executor cat /etc/pacman.conf)"	
	RESULT_PACMAN_CONF="$(echo "${RESULT_PACMAN_CONF}" | sed "s/Server = https:\/\/cd2\.holoiso\.ru\.eu\.org\/pkg\/\$repo\/os\/\$arch//g")"
sudo_executor tee /etc/pacman.conf &> /dev/null <<EOF
${RESULT_PACMAN_CONF}
EOF
fi

ORIG_PACMAN_CONF="$(sudo_executor cat /etc/pacman.conf)"
if ( sudo_executor cat /etc/pacman.conf | grep "holostaging" );then
	echo Removing holoiso-next from /etc/pacman.conf
	# https://stackoverflow.com/questions/25224994/how-to-bash-cat-or-tee-into-a-file-with-sudo-with-eof-and-with-silent-output
	RESULT_PACMAN_CONF="$(echo "${ORIG_PACMAN_CONF}" | sed 's/\[holostaging\]//g')"
sudo_executor tee /etc/pacman.conf &> /dev/null <<EOF
${RESULT_PACMAN_CONF}
EOF
ORIG_PACMAN_CONF="$(sudo_executor cat /etc/pacman.conf)"	
	RESULT_PACMAN_CONF="$(echo "${RESULT_PACMAN_CONF}" | sed "s/Server = https:\/\/cd2\.holoiso\.ru\.eu\.org\/pkg\/\$repo\/os\/\$arch//g")"
sudo_executor tee /etc/pacman.conf &> /dev/null <<EOF
${RESULT_PACMAN_CONF}
EOF
fi


sudo_executor pacman-key --init
sudo_executor pacman-key --populate
sudo_executor pacman -Sy --noconfirm --overwrite \\\'*\\\'
HOLO_REL="$(sudo_executor cat /etc/pacman.conf | grep "^\[holo" | sed 's/\[//g' | sed 's/\]//g')"
if [ -n "${HOLO_REL}" ];then
sudo_executor pacman -S base-devel --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S ${HOLO_REL}/linux-headers --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S linux-neptune-headers --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S ${HOLO_REL}/linux-lts-headers --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S git --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S lib32-glibc glibc --noconfirm
sudo_executor pacman -S gcc --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S gcc-libs --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S fakeroot --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S linux-api-headers --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S libarchive --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S go --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S git --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S wget --noconfirm --overwrite \\\'*\\\'
fi

sudo_executor pacman -S base-devel --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S go --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S git --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S wget --noconfirm --overwrite \\\'*\\\'
sudo_executor pacman -S gamescope --noconfirm --overwrite \\\'*\\\'

# Install yay
cd $HOME
git clone https://github.com/Jguer/yay.git
cd $HOME/yay
git pull
git checkout v11.0.0
make
SHELL_RUN_COMMANDS=`find	~ -maxdepth 1 -name '.*shrc'`
touch ~/.bashrc
find ~/ -type f -name '.*shrc' -maxdepth 1 -exec sh -c 'grep -w "export PATH=\${PATH}:$(pwd)$" {} || echo "export PATH=\${PATH}:$(pwd)" >> {}' \;
export PATH=${PATH}:$(pwd)

go get github.com/ericchiang/pup
go install github.com/ericchiang/pup@latest


# Add chaotic-aur
CHAOTICAUR_INSTALL_COMMANDS="$(curl -LsSf https://aur.chaotic.cx/ | $HOME/go/bin/pup ':parent-of(#howto) .command' | tr -d '\n'| $HOME/go/bin/pup '.command text{}' | sed "s/\&\#39\;//g" | sed "s/pacman\ \-/pacman\ \-\-noconfirm\ \-/g")"
# https://unix.stackexchange.com/questions/9784/how-can-i-read-line-by-line-from-a-variable-in-bash
while IFS= read -r line
do
	echo $line
	sudo_executor $line
done < <(printf '%s\n' "$CHAOTICAUR_INSTALL_COMMANDS")

# Add chaotic-aur to pacman.conf
if ( sudo_executor cat /etc/pacman.conf | grep "chaotic-aur" );then
	echo Skipping to add chaotic-aur to /etc/pacman.conf
else
	echo Adding chaotic-aur to /etc/pacman.conf
	RESULT_PACMAN_CONF="$(sudo_executor cat /etc/pacman.conf)"
sudo_executor tee /etc/pacman.conf &> /dev/null <<EOF
${RESULT_PACMAN_CONF}
$(curl -LsSf https://aur.chaotic.cx/ | $HOME/go/bin/pup ':parent-of(#howto) :contains("Include")' | tr -d '\n' | $HOME/go/bin/pup ':contains("Include") text{}')
EOF
fi


# Add chaotic-mirrorlist
sudo_executor tee /etc/pacman.d/chaotic-mirrorlist &> /dev/null <<EOF
## special cdn mirror (delayed syncing, expect some (safe to ignore) amount of 404s)
# globally
# * by: garuda linux donators, hosted on cloudflare r2
server = https://cdn-mirror.chaotic.cx/\$repo/\$arch

# automatic per-country routing of the mirrors below.
server = https://geo-mirror.chaotic.cx/\$repo/\$arch

## regular syncthing mirrors (close to instant syncing)
# brazil
# * by: universidade federal de são carlos (são carlos)
server = https://br-mirror.chaotic.cx/\$repo/\$arch

# bulgaria
# * by: sudo man <github.com/sakrayaami>
server = https://bg-mirror.chaotic.cx/\$repo/\$arch

# canada
# * by freebird54 (toronto)
server = https://ca-mirror.chaotic.cx/\$repo/\$arch

# chile
# * by makzk (santiago)
server = https://cl-mirror.chaotic.cx/\$repo/\$arch

# germany (de-1 ceased to exist)
# * by: paranoidbangl
server = https://de-2-mirror.chaotic.cx/\$repo/\$arch
# * by: itstyrion
server = https://de-3-mirror.chaotic.cx/\$repo/\$arch
# * by: redgloboli
server = https://de-4-mirror.chaotic.cx/\$repo/\$arch

# france
# * by yael (marseille)
server = https://fr-mirror.chaotic.cx/\$repo/\$arch

# greece
# * by: vmmaniac <github.com/vmmaniac>
server = https://gr-mirror.chaotic.cx/\$repo/\$arch

# india
# * by naman (kaithal)
server = https://in-mirror.chaotic.cx/\$repo/\$arch
# * by albony <https://albony.xyz/>
server = https://in-2-mirror.chaotic.cx/\$repo/\$arch
# * by: bravo68dev <https://www.itsmebravo.dev/>
server = https://in-3-mirror.chaotic.cx/\$repo/\$arch
# * by albony (chennai)
server = https://in-4-mirror.chaotic.cx/\$repo/\$arch

# korea
# * by: <t.me/silent_heigou> (seoul)
server = https://kr-mirror.chaotic.cx/\$repo/\$arch

# spain
# * by: jkanetwork
server = https://es-mirror.chaotic.cx/\$repo/\$arch
# * by: ícar <t.me/icarns>
server = https://es-2-mirror.chaotic.cx/\$repo/\$arch

# united states
# * by: technetium1 <github.com/technetium1>
server = https://us-mi-mirror.chaotic.cx/\$repo/\$arch
# new york
# * by: xstefen <t.me/xstefen>
server = https://us-tx-mirror.chaotic.cx/\$repo/\$arch
# utah
# * by: ash <t.me/the_ashh>
server = https://us-ut-mirror.chaotic.cx/\$repo/\$arch


# ipfs mirror - for instructions on how to use it consult the projects repo (https://github.com/rubenkelevra/pacman.store)
# * by: rubenkelevra / pacman.store
# server = http://chaotic-aur.pkg.pacman.store.ipns.localhost:8080/\$arch
EOF

sudo_executor pacman -Sy --noconfirm --overwrite \\\'*\\\'

if [ -z "$(which yay || echo A | grep A)" ];then # When yay was not found in PATH
	sudo_executor pacman -S yay --noconfirm --overwrite \\\'*\\\'
fi

#shc
cd $HOME
git clone https://aur.archlinux.org/shc.git
cd shc
git pull
makepkg -Sfi
makepkg -i --noconfirm


#nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#npm
nvm install --lts
nvm use --lts

#pnpm
sudo_executor npm i -g pnpm


#Build
cd ~/
git clone https://github.com/${__ORG_NAME__}/${__REPO_NAME__}.git
cd ~/${__REPO_NAME__}
bash ./build.sh


#Add to Steam
pnpm i
pnpm add:steam

