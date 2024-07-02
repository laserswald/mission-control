#!/bin/sh

if ! dpkg -s "wireguard" >/dev/null 2>&1; then
	echo "Installing wireguard..."
	apt-get install wireguard wireguard-tools
fi

if ! [ -f "/etc/wireguard/privatekey" ] || ! [ -f "/etc/wireguard/publickey" ]; then
	echo "Generating public and private keys..."
	wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
fi

