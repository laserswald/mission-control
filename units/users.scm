(import (scheme base)
        (ultrawave base)
        (ultrawave user))

(define guest-groups
  '(guest dev))

;; Set up my user.
(define (users-set-up secret-storage)
  (property-group "Users set up."
    (user-exists/groups "lazr" 'wheel 'docker)))


;; Set up a guest user.
(define (guest-user-set-up username)
  (property-group (show #f "User " username " exists.")
    (apply user-exists/groups username guest-groups)))

;; Set up a system user.
;; System users are quite locked down.

;; Set up all the guest users passed.
(define (guest-users-set-up users)
  (apply property-group
         (show #f "Guest users set up.")
         (map guest-user-set-up users)))


(define (install-key! host)
  (do-process! `(ssh-copy-id ,(string-append "lazr@" (host-name host)))))


(define (install-keys! hosts)
  (for-each install-key! hosts))
