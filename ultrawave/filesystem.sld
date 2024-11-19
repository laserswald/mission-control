
(define-library (ultrawave filesystem)
  (export directory-exists 
          remote-file-exists?
          file-owned-by
          file-permissions-set
          file-copied-to
          file-copied-from
          local-directory-exists
          file-linked/hard
          file-linked/symbolic

          file-has-line)
          

  (import (scheme base) 
          (scheme show)
          (ultrawave base)
          (ultrawave property)
          (ultrawave command)
          (gauche process))

  (begin

    (define (file-exists? filename)
      (do-remote-process `(test -f ,filename)))
   
    (define (directory-exists name)
      (property
       (lambda ()
         (do-remote-process `(test -d ,name)))
       (lambda ()
         (do-remote-process! `(mkdir -p ,name))
         (log/remote-host "Directory exists: " name))
       (lambda ()
         (do-remote-process! `(rm -rf ,name)))))

    (define (file-owned-by filename user group)
      (shell-command-property  `(chown ,(string-append user ":" group) ,filename)
                               (show #f "Changed ownership of " filename " to " user ":" group)))
  
    ;;;
    ;;; Ensure that the FILENAME has the chmod-compatible PERMISSIONS set.
    ;;;
    (define (file-permissions-set filename permissions)
      (shell-command-property `(chmod ,permissions ,filename)
                              (show #f "Changed permissions of " filename " to " permissions)))
   
    ;;;
    ;;; Establish a symbolic link named LINKNAME that points to TARGET.
    ;;;
    (define (file-linked/symbolic target linkname)

      ;; TODO: check that the link actually points to the correct item
      (define (applied?)
        (do-remote-process! `(test ! -L ,linkname)))

      (define (apply!)
        (do-remote-process! `(ln -s ,target ,linkname))
        (show #f "Symlinked " linkname " to point to " target))

      (define (unapply!)
        (do-remote-process! `(rm -rf ,name)))

      (property applied? apply! unapply!))


    (define (file-linked/hard target linkname)
      (shell-command-property `(ln ,target ,linkname)
                              (show #f "Hardlinked " linkname " to point to " target)))

    (define (file-copied-to local-file destination)
      (property
       (lambda ()
         (do-remote-process `(test -d ,destination)))
       (lambda ()
         (do-process! `(scp ,local-file
                            ,(string-append (current-host-login-string) ":" destination)))
         (log/remote-host "File copied to:" destination))
       (lambda ()
         (do-remote-process! `(rm -f ,destination)))
       '()))

    (define (file-copied-from remote-file destination)
      (log/remote-host `(scp ,(string-append (current-host-login-string) ":" remote-file)
                         ,destination))
      (do-process! `(scp ,(string-append (current-host-login-string) ":" remote-file)
                         ,destination)))

    (define (file-has-line file line)
      (define (applied?)
        (do-remote-process `(grep --silent --fixed-strings ,line ,file)))
      (define (apply!)
        (do-remote-process `(echo ,line >> ,file)))
      (define (unapply!)
        (let ((tempname #f))
          (dynamic-wind
            (lambda ()
              (set! tempname (process->string/remote '(mktemp))))
            (lambda ()
              (do-remote-process! `(grep --invert-match --fixed-strings ,line ,file > ,tempname)))
            (lambda ()
              (do-remote-process! `(rm -rf ,tempname))))))
      (property applied? apply! unapply!))

    (define (local-directory-exists name)
      (do-process! `(mkdir -p ,name)))))

