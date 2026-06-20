(import (scheme base)
        (scheme write))
(import (srfi 64))

(import (ultrawave base))
(import (ultrawave host))
(import (ultrawave property))

(define demo-property
  (property
   (lambda ()
     (display "My remote host is ")
     (show-host (current-remote-host))
     (newline))))

(define silly-host
  (host "silly-willy"))

(configure! (list demo-property) silly-host)
