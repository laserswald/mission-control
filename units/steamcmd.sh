#! /bin/sh
#
#

. units/users.sh

ensure_user "steam"

if dpkg -s "steamcmd" >/dev/null 2>&1; then
	return 0
fi

# Ensure that the non-free repository is enabled.
if ( grep "bookworm" | grep -q "non-free" ); then
	echo "Enable non-free for your debian installation"
	exit 1
fi

dpkg --add-architecture i386

apt update
echo "2" | apt-get install -y steamcmd
