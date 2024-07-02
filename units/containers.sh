#! /bin/sh
#
# Set this node up for containerized workloads.

if ! dpkg -s "podman" >/dev/null 2>&1; then
	echo "Installing podman."
	apt-get install podman
fi

