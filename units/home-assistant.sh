#! /bin/sh
#
# Ensure home-assistant is installed on the target machine.

. units/users.sh
. units/containers.sh

ensure_user "home-assistant"
echo "User for home-assistant exists."

mv units/home-assistant/home-assistant.service /etc/systemd/system/
echo "Installed home-assistant service."

systemctl enable --now home-assistant
echo "Enabled home-assistant service."

