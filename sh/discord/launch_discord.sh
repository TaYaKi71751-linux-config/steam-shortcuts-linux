#!/bin/bash

#Discord
if ( uname -a | grep x86_64 );then
	if ( which discord );then
		discord
	else
		/usr/bin/flatpak "run" "--branch=stable" "--file-forwarding" "com.discordapp.Discord" "@@u" "@@"
	fi
else
	/usr/bin/flatpak "run" "--branch=stable" "--file-forwarding" "com.discordapp.Discord" "@@u" "@@"
fi
