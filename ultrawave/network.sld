(define-library (ultrawave network)
  (export ip-forwarding-enabled
          hostname-set)
  (import (scheme base)
          (scheme show)
          (ultrawave base)
          (ultrawave property)
          (ultrawave command))

  (begin

    ;;; Enable IP forwarding packets, making the host into a router
    (define ip-forwarding-enabled
      (shell-command-property
       `(sysctl net.ipv4.ip_forward=1)
       "Enabled IP forwarding."))))
