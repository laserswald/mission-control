
(define-library (ultrawave user)
  (export user-exists
          user-password-generated)

  (import (scheme base) 
          (scheme show)
          (gauche base)
          (gauche process)
          (ultrawave base))

  (begin

    (define (user-exists name)
      (property 
       (lambda () 
         (do-remote-process `(id ,name)))
       (lambda ()
         (do-remote-process! `(useradd --user-group --create-home ,name))
         (log/remote-host "User" name "created."))
       (lambda ()
         (do-remote-process! `(userdel ,name)))
       '()))
   
   
    (define (user-password-generated username secret-storage)
      (let ((secret-path (string-append "sys/" (host-nick (current-remote-host)) "/" username)))
        (property
         (lambda ()
           (secret-storage-ref secret-storage secret-path))
         (lambda ()
           (do-process! `(pass generate ,secret-path))
           (do-process! `(passwd ,username)
                        :host (current-host-login-string)
                        :redirects ((<< ))
         (lambda ()
           (secret-storage-remove! secret-storage secret-path))
         
         '()
         )))

   ))
