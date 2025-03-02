
GOSHFLAGS=-r7 -A. -Alib

repl:
	gosh $(GOSHFLAGS)

interact:
	gosh $(GOSHFLAGS) -l mission-control.scm

configure-all:
	gosh $(GOSHFLAGS) -e '(import (scheme load)) (load "mission-control.scm") (configure-all!)'
