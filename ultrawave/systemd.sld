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
   
    (define (apply-services host)
      (define (restart-services)
        (let ((services (host-extras-ref host 'services-need-restart)))
          (if (and services
                   (not (null? restart-services)))
              (do-remote-process! `(systemctl restart ,@services)))))

      (define (enable-services)
        (let ((services (host-extras-ref host 'services-need-enable)))
          (if (and services
                   (not (null? restart-services)))
              (do-remote-process! `(systemctl enable --now ,@services)))))

      
      (restart-services)
      (enable-services))
   
    (define (register-enable-services . names)
      (host-extras-adjoin! (current-remote-host) 'services-need-enable names))

    (define (register-services-restart . names)
      (host-extras-adjoin! (current-remote-host) 'services-need-restart names))
   
    (define (make-systemctl-command-property command)
      (lambda names
        (shell-command-property
         `(systemctl ,command --now ,@names)
         (show #f "Services " (symbol->string command) "d: " names)))
      
    (define services-enabled (make-systemctl-command-property 'enable))
    (define services-disabled (make-systemctl-command-property 'disable))
    (define services-restarted (make-systemctl-command-property 'restart))

   ))

