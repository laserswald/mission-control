
VANILLA_INSTALL_DIR := /var/games/minecraft
VANILLA_SCRIPTS := start.sh upgrade.sh
VANILLA_SCRIPT_DESTS := $(patsubst %,$(VANILLA_INSTALL_DIR)/%,$(VANILLA_SCRIPTS))

.PHONY: vanilla-status
vanilla-status:
	$(SSH) $(HOST) "systemctl status minecraft@vanilla"

status: vanilla-status

.PHONY: vanilla-install
vanilla-install: $(VANILLA_SCRIPTS)
	@$(SCP) $^ $(HOST):/tmp/
	@$(SSH) $(HOST) "\
		cd /tmp; \
		mv $^ $(VANILLA_INSTALL_DIR); \
		chmod 755 $(VANILLA_SCRIPT_DESTS); \
		echo '$$(pass sys/sol/lazr)' | sudo -S chown minecraft:minecraft $(VANILLA_SCRIPT_DESTS); \
	"

.PHONY: vanilla-start
vanilla-start:
	@$(SSH) $(HOST) "echo '$$(pass sys/sol/lazr)' | sudo -S systemctl restart minecraft@vanilla"

.PHONY: vanilla-upgrade
vanilla-upgrade: vanilla-install
	$(SSH) $(HOST) "cd $(VANILLA_INSTALL_DIR); ./upgrade.sh"
