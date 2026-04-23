.POSIX:
SCHEME=gosh -r7
SCHEMEFLAGS=-A. -Alib

#
#
#

deploy:
	$(SCHEME) $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-all!) (exit)'

repl:
	$(SCHEME) $(GOSHFLAGS) -l mission-control.scm

clean:
	find . -iname "#*#" -o -iname "*~" -delete

#
# Build a host only
#

french-fry:
	$(SCHEME) $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-french-fry!) (exit)'

andromeda:
	$(SCHEME) $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-andromeda!) (exit)'

chip:
	$(SCHEME) $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-chip!) (exit)'

sol:
	$(SCHEME) $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-sol!) (exit)'

#
# Deploy an application
#

rewards-app:
	$(SCHEME) $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (install-rewards-app!) (exit)'

lazr-space.conf:
	$(SCHEME) $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (lazr/generate-ssh-config) (exit)'

