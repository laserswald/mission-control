
(define-library (ultrawave filesystem)
  (export directory-exists 
          remote-file-exists?
          file-owned-by
          file-permissions-set
          file-copied-to
          file-copied-from
          local-directory-exists)

  (import (scheme base) 
          (ultrawave base)
          (gauche process))

  (begin

   (define (file-exists? filename)
     (do-remote-process `(test -f ,filename)))
   
   (define (directory-exists name)
     (property
      (lambda ()
        (do-remote-process `(test -d ,filename)))
      (lambda ()
        (do-remote-process! `(mkdir -p ,name))
        (log/remote-host "Directory exists: " name))
      (lambda ()
        (do-remote-process! `(rm -rf ,name)))
      '()))
   
   (define (file-owned-by filename user group)
     (shell-command-property  `(chown ,(string-append user ":" group) ,filename)
                              (show #f "Changed ownership of " filename " to " user ":" group)))
   
   (define (file-permissions-set filename permissions)
     (shell-command-property `(chmod ,permissions ,filename)
                             (show #f "Changed permissions of " filename " to " permissions)))

   (define (file-copied-to local-file destination)
     (do-process! `(scp ,local-file 
                        ,(string-append (current-host-login-string) ":" destination))))

   (define (file-copied-from remote-file destination)
     (log/remote-host `(scp ,(string-append (current-host-login-string) ":" remote-file)
                        ,destination))
     (do-process! `(scp ,(string-append (current-host-login-string) ":" remote-file)
                        ,destination)))

   (define (local-directory-exists name)
     (do-process! `(mkdir -p ,name)))))

