(define-library (ultrawave network)
  (export ip-forwarding-enabled)
  (import (scheme base)
          (ultrawave base)
          (ultrawave property)
          (ultrawave command))

  (begin

    ;;; Enable IP forwarding packets, making the host into a router
    (define ip-forwarding-enabled
      (shell-command-property
       `(sysctl net.ipv4.ip_forward=1)
       "Enabled IP forwarding."))))
