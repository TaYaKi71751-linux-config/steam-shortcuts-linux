#!/bin/bash

	sudo ps -A | grep tailscaled && \
	sudo tailscale up --qr --operator=$HOSTNAME --ssh --exit-node=$TAILSCALE_EXIT_NODE --exit-node-allow-lan-access || \
	(sudo systemd-run tailscaled && \
	sudo tailscale up --qr --operator=$HOSTNAME --ssh --exit-node=$TAILSCALE_EXIT_NODE --exit-node-allow-lan-access)

