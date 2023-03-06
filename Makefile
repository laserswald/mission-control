SSH := ssh
SCP := scp

MODDED_SERVER := sirius.lazr.space
.DEFAULT: status

status:

install:
	@echo "Installed everything!"

-include minecraft.mk
-include znc.mk
-include website.mk
-include ftb.mk
-include wireguard.mk
-include gitolite.mk
