
SSH := ssh
SCP := scp

VANILLA_SERVER := sol.lazr.space
MODDED_SERVER := sirius

VANILLA_INSTALL_DIR := /var/games/minecraft
VANILLA_SCRIPTS := start.sh upgrade.sh
VANILLA_SCRIPT_DESTS := $(patsubst %,$(VANILLA_INSTALL_DIR)/%,$(VANILLA_SCRIPTS))

vanilla-status:
	$(SSH) $(VANILLA_SERVER) "systemctl status minecraft@vanilla"

vanilla-install: $(VANILLA_SCRIPTS)
	@$(SCP) $^ $(VANILLA_SERVER):/tmp/
	@$(SSH) $(VANILLA_SERVER) "\
		cd /tmp; \
		mv $^ $(VANILLA_INSTALL_DIR); \
		chmod 755 $(VANILLA_SCRIPT_DESTS); \
		echo '$$(pass sys/sol/lazr)' | sudo -S chown minecraft:minecraft $(VANILLA_SCRIPT_DESTS); \
	"

vanilla-start:
	@$(SSH) $(VANILLA_SERVER) "echo '$$(pass sys/sol/lazr)' | sudo -S systemctl restart minecraft@vanilla"

vanilla-upgrade: vanilla-install
	$(SSH) $(VANILLA_SERVER) "cd $(VANILLA_INSTALL_DIR); ./upgrade.sh"
