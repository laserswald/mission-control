(define-library (ultrawave base)

  (export log/remote-host
          configure!)

  (import (scheme base)
          (scheme process-context)
          (scheme show)
          (gauche base)
          (gauche process))

  (import (ultrawave host))
  (export host host? host-user host-name host-nick host-protocol host-package-manager
          show-host host-login-string host-alive?
          localhost
          current-remote-host current-host-login-string)

  (import (ultrawave property))
  (export property 
          property-should-apply? 
          property-apply! 
          ensure-property! 
          property-group 
          performed-on-host)

  (begin

    ;;; (configure! (list-of property?) host?)
    ;;;
    ;;; Apply the properties in order to the host. 
    (define (configure! configuration host)
      (parameterize ((current-remote-host host)) 
        (for-each (lambda (property)
                    (ensure-property! property))
                  configuration)))

    ;;; (log/remote-host . any?)
    ;;;
    ;;; Write to the logger t
    (define (log/remote-host . message)
      (show #t 
            (as-green "[" (host-nick (current-remote-host)) "]")
            " "
            (joined displayed message " ")
            nl))))
   

