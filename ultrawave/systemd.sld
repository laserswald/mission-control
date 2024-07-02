
(define-library (ultrawave systemd)
  (export services-enabled
          services-disabled)

  (import (scheme base) 
          (scheme show)
          (ultrawave base))

  (begin

   (define (services-enabled . names)
     (shell-command-property 
      `(systemctl enable --now ,@names)
      (show #f "Services enabled:" names)))
   
   (define (services-disabled . names)
     (shell-command-property
      `(systemctl disable --now ,@names)
     (show #f "Services disabled:" names)))
   
   ))

