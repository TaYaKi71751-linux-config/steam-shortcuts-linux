#!/bin/bash

	sudo ps -A | grep tailscaled && \
	sudo tailscale down || \
	(sudo systemd-run tailscaled && \
	sudo tailscale down

