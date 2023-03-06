.POSIX:

.DEFAULT_GOAL: install

include hosts/andromeda.mk
include hosts/sirius.mk
include hosts/sol.mk
include roles/wireguard.mk

install: sirius

