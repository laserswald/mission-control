
GOSHFLAGS=-r7 -A. -Alib

deploy:
	gosh $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-all!) (exit)'

repl:
	gosh $(GOSHFLAGS) -l mission-control.scm

french-fry:
	gosh $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-french-fry!) (exit)'

chip:
	gosh $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-chip!) (exit)'

sol:
	gosh $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-sol!) (exit)'

lazr-space.conf:
	gosh $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (lazr/generate-ssh-config) (exit)'
