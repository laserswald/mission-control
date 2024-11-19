;;;; ultrawave systemd - Support for enabling/disabling services
;;;;
(define-library (ultrawave systemd)
  (export services-enabled
          services-disabled
          services-restarted)

  (import (scheme base) 
          (scheme show)
          (ultrawave base)
          (ultrawave command))

  (begin 

    ;;; (services-enabled (names (list-of string?)) -> property?
    ;;;
    ;;; Enables the list of services named `names` on the remote host.
    (define (services-enabled . names)
      (shell-command-property 
       `(systemctl enable --now ,@names)
       (show #f "Services enabled:" names)))
   
    ;;; (services-disabled (names (list-of string?)) -> property?
    ;;;
    ;;; Disables the list of services named `names` on the remote host.
    (define (services-disabled . names)
      (shell-command-property
       `(systemctl disable --now ,@names)
       (show #f "Services disabled:" names)))

    (define (services-restarted . names)
      (shell-command-property
       `(systemctl restart ,@names)
       (show #f "Services restarted:" names)))))

