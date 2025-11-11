#!/usr/bin/env bash
#
# Monitors my servers to ensure that things are alive.

set -euo pipefail

SERVERS=(
    "lazr.space 443"
    "mc.lazr.space 25565"
    "mc.lazr.space 25567"
)

declare -a FAILING_SERVERS
export FAILING_SERVERS

for host in "${SERVERS[@]}"; do
	if ! nc -w 10 -z $host; then
	    echo "Could not connect to $host"
	    FAILING_SERVERS+=("$host")
	fi
done


# if [[ ${#SERVERS[@]} -ne 0 ]]; then
if [[ ${#FAILING_SERVERS[@]} -ne 0 ]]; then
	sendmail -t -F "Lazr.Space System Monitor Bot" <<EOF
To: me@lazr.space, ben.davenportray@gmail.com
Subject: [ALERT] Servers unreachable!

The following hosts and ports are currently unreachable:

${FAILING_SERVERS[@]}

This alert will continue every so often until it is resolved.

--
Sincerely yours,
The server monitor script <3
EOF

fi
