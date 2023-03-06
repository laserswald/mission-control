#!/bin/sh
#
# Remotely install a file.

HOST=$1; shift

scp $@ $HOST:/tmp/

ssh $HOST "\
	cd /tmp; \
	mv $^ $(VANILLA_INSTALL_DIR); \
	chmod 755 $(VANILLA_SCRIPT_DESTS); \
	echo '$$(pass sys/sol/lazr)' | sudo -S chown minecraft:minecraft $(VANILLA_SCRIPT_DESTS); \
"
