(import (scheme base)
        (gauche reload))

(define (system-user name)
  (property-group
   (show #f "System user " name " added.")
   (user-exists name)))
