#!/bin/sh
set -e
. "/etc/profile.d/openjdk.sh"
cd "/srv/minecraft/$1"
java -Xmx1512M -Xms512M -jar server.jar nogui noconsole
