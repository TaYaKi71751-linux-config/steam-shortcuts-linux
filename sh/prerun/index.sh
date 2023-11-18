#!/bin/bash


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

sudo_executor pacman-key --init
sudo_executor pacman-key --populate
sudo_executor pacman -Sy --noconfirm

sudo_executor pacman -Syu \
  base-devel \
  holo-rel/linux-headers \
  linux-neptune-headers \
  holo-rel/linux-lts-headers \
  git glibc gcc gcc-libs \
  fakeroot linux-api-headers \
  libarchive \
  go \
  git \
  wget \
  --noconfirm

sudo_executor pacman -Syu \
  base-devel \
  go \
  git \
  wget \
  --noconfirm

# Install yay
cd /tmp
rm -rf /tmp/yay/
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd /tmp/yay
makepkg -Si --force
makepkg -i --noconfirm

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


#shc
yay -S shc --noconfirm

#nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#npm
nvm install --lts
nvm use --lts

#pnpm
sudo npm i -g pnpm

#brew
curl -LsSf https://raw.githubusercontent.com/raccl/packages/archlinux/packages/brew.sh | sh

#flatpak
sudo pacman -Syu \
  flatpak \
  --noconfirm

#tailscale
mkdir -p ~/.local/tailscale/steamos
cd ~/.local/tailscale/steamos
mkdir -p tailscale
cd tailscale
git init
git remote add origin https://github.com/tailscale/tailscale.git
git pull origin main
git checkout origin/main
./build_dist.sh tailscale.com/cmd/tailscale
./build_dist.sh tailscale.com/cmd/tailscaled
touch ~/.bashrc
find ~/ -type f -name '.*shrc' -maxdepth 1 -exec sh -c 'grep -w "export PATH=\${PATH}:$(pwd)$" {} || echo "export PATH=\${PATH}:$(pwd)" >> {}' \;
export PATH=${PATH}:$(pwd)

#Microsoft Edge
flatpak install flathub com.microsoft.Edge --assumeyes

#OBS Studio
flatpak install com.obsproject.Studio.Plugin.OBSVkCapture --assumeyes
flatpak install org.freedesktop.Platform.VulkanLayer.OBSVkCapture --assumeyes
flatpak install flathub com.obsproject.Studio --assumeyes

#Discord
flatpak install flathub com.discordapp.Discord --assumeyes

#Build
cd ~/
git clone https://github.com/TaYaKi71751/steam-shortcuts.git
cd ~/steam-shortcuts
bash ./build.sh


#Add to Steam
pnpm i
pnpm add:steam

