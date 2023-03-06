
vpn-server: install-wireguard

vpn-client: install-wireguard

install-wireguard:
	bin/root-command.sh $(HOST) "apt install wireguard wireguard-tools"
	bin/root-command.sh $(HOST) "wg genkey | tee /etc/wireguard/privatekey | wg publickey > /etc/wireguard/publickey"

