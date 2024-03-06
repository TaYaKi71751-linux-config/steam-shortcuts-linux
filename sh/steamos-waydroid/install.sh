#!/bin/bash

bash << EOF
function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}
auto_path git
cd ~/
git clone https://github.com/ryanrudolfoba/steamos-waydroid-installer
cd ~/steamos-waydroid-installer
git pull
chmod +x steamos-waydroid-installer.sh
./steamos-waydroid-installer.sh
EOF
