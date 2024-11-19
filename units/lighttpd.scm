
(import (scheme base)
        (ultrawave base)
        (ultrawave pacman)
        (ultrawave command)
        (ultrawave apt)
        (ultrawave property))

(define lighttpd-enabled/arch
  (package-service-enabled/pacman "lighttpd"))

(define lighttpd-enabled/debian
  (package-service-enabled/apt "lighttpd"))

(define (lighttpd-tested-config file)
  (shell-command-property 
   `(lighttpd -t -f ,file)
   (show #f "Configuration file for lighttpd is OK:" file)))

