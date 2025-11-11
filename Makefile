
GOSHFLAGS=-r7 -A. -Alib

deploy:
	gosh $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-all!) (exit)'

repl:
	gosh $(GOSHFLAGS) -l mission-control.scm

french-fry:
	gosh $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-french-fry!) (exit)'
