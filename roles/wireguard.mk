

.PHONY: vpn-server
vpn-server: install-wireguard

.PHONY: vpn-client
vpn-client: install-wireguard

.PHONY: install-wireguard
install-wireguard:
	bin/root-command.sh $(HOST) "apt install wireguard wireguard-tools"
	bin/root-command.sh $(HOST) "wg genkey | tee /etc/wireguard/privatekey | wg publickey > /etc/wireguard/publickey"

