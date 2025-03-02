
(define-library (ultrawave user)
  (export user-exists
          group-exists
          user-exists/groups
          system-user-exists)
          

  (import (scheme base) 
          (scheme show)
          (scheme text)
          (gauche base)
          (gauche process)
          (ultrawave base)
          (ultrawave property)
          (ultrawave command))

  (begin

    (define (user-exists name)
      (property 
       (lambda () 
         (do-remote-process `(id ,name >/dev/null)))
       (lambda ()
         (do-remote-process! `(useradd --user-group --create-home ,name))
         (log/remote-host "User" name "created."))
       (lambda ()
         (do-remote-process! `(userdel ,name)))
       '()))

    (define (group-exists name)
      (define (applied?)
        (do-remote-process `(getent group ,name >/dev/null)))
      (define (apply!) 
        (do-remote-process! `(groupadd ,name))
        (log/remote-host "Group " name "created."))
      (define (unapply!)
        (do-remote-process! `(groupdel ,name)))
      (property applied?
                apply!
                unapply!))
   
    (define (user-exists/groups user . groups)
      (define (apply!)
        (do-remote-process! 
         `(usermod --append --groups ,(textual-join (map symbol->string groups) ",") ,user))
        (log/remote-host "User added to groups: " groups))
      (property #f
                apply!
                #f
                (append (list (user-exists user))
                        (map group-exists groups))))
   
    (define (system-user-exists name)
      (property 
       (lambda () 
         (do-remote-process `(id ,name)))
       (lambda ()
         (do-remote-process! `(useradd --add-subids-for-system
                                       --system
                                       --user-group
                                       --create-home
                                       ,name))
         (log/remote-host "System user" name "created."))
       (lambda ()
         (do-remote-process! `(userdel ,name)))
       '()))
   
   
    #;(define (user-password-generated username secret-storage)
       (let ((secret-path (string-append "sys/" (host-nick (current-remote-host)) "/" username)))
         (property
          (lambda ()
            (secret-storage-ref secret-storage secret-path))
          (lambda ()
            (do-process! `(pass generate ,secret-path))
            (do-process! `(passwd ,username)
                         :host (current-host-login-string)
                         :redirects ((<<))
             (lambda ()
               (secret-storage-remove! secret-storage secret-path))
         
             '())))))))
         

   
