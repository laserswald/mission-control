#!/usr/bin/env bash
#
# Monitors my servers to ensure that things are alive.

set -euo pipefail

DEBUG_MODE=0

SERVERS=(
    "lazr.space 443"
    "mc.lazr.space 25565"
    "mc.lazr.space 25566"
)

FAILING_SERVERS=""

for host in "${SERVERS[@]}"; do
    if ! nc -w 10 -z $host; then
	echo "Could not connect to $host"
	FAILING_SERVERS="$FAILING_SERVERS$host\n"
    fi
done

# echo $FAILING_SERVERS

# if [[ ${#SERVERS[@]} -ne 0 ]]; then
if [[ ${FAILING_SERVERS} || ($DEBUG_MODE -ne 0)]]; then
    if [ $DEBUG_MODE -ne 0 ]; then	
	alertcmd="cat"
    else
	alertcmd="sendmail -t -F lazr.space"
    fi
    $alertcmd <<EOF
To: me@lazr.space, ben.davenportray@gmail.com
Subject: [ALERT] Servers unreachable!

The following hosts and ports are currently unreachable:

${FAILING_SERVERS}

This alert will continue every so often until it is resolved.

--
Sincerely yours,
The server monitor script <3
EOF

fi
