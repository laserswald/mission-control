
(define-library (ultrawave filesystem)
  (export directory-exists
          directory-owned-by/rec
          directory-permissions-set/rec
	  file-owned-by
	  file-permissions-set
          file-copied-to
          file-copied-from
          file-linked/hard
          file-linked/symbolic
          file-has-line

	  remote-file-exists?
	  remote-directory-exists?
	  create-local-directory!
	  create-remote-directory!
	  call-with-local-temporary-filename
	  copy-local-file!
	  copy-remote-file!
	  set-remote-file-contents!
	  )
          

  (import (scheme base) 
          (scheme show)
          (ultrawave base)
          (ultrawave property)
          (ultrawave command)
          (gauche process))

  (begin

    ;;; Does the FILENAME exist on the remote host?
    (define (remote-file-exists? filename)
      (do-remote-process `(test -f ,filename)))

    ;;; Does the PATHNAME exist on the remote host?
    (define (remote-directory-exists? pathname)
      (do-remote-process `(test -d ,pathname)))

    ;;; Creates the file path given, including all parent paths.
    (define (create-local-directory! path)
      (do-process! `(mkdir -p ,path)))

    (define (create-remote-directory! path)
      (do-remote-process! `(mkdir -p ,path)))

    ;;; Call a procedure with an automatically cleaned up temporary file name.
    (define (call-with-local-temporary-filename proc)
      (let ((tempname #f))
	(dynamic-wind
	  (lambda ()
	    (set! tempname (process->string '(mktemp))))
	  (lambda ()
	    (proc tempname))
	  (lambda ()
	    (do-process! `(rm -rf ,tempname))))))

    ;;; Copies a local file using `scp` to the given destination at the remote host.
    (define (copy-local-file! local-file destination)
      (do-process! `(scp ,local-file
			 ,(string-append (current-host-login-string) ":" destination))))
 
    ;;; Copy a remote file to the current host, at the given destination.
    (define (copy-remote-file! remote-file destination)
      (do-process! `(scp ,(string-append (current-host-login-string) ":" remote-file)
                         ,destination)))

    ;;; Set a remote file's contents to the list of strings given.
    (define (set-remote-file-contents! file contents)
      (call-with-local-temporary-filename
       (lambda (tempname)
	 (with-output-to-file tempname
	   (for-each (lambda (ln)
		       (write ln)
		       (newline))
		     contents))
	 (copy-local-file! tempname file))))

    ;;;;
    ;;;; Directory properties.
    ;;;;

    ;;; Ensures that the directory with the given name exists on the remote system.
    (define (directory-exists name)
      (property
       (lambda ()
         (log/remote-host "Checking for directory existence: " name)
         (remote-directory-exists? name))
       (lambda ()
         (do-remote-process! `(mkdir -p ,name))
         (log/remote-host "Directory exists: " name))
       (lambda ()
         (do-remote-process! `(rm -rf ,name)))))

    ;;; Ensures that the local file is copied to the destination.
    (define (file-copied-to local-file destination)
      (property
       (lambda ()
         (remote-directory-exists? destination))
       (lambda ()
	 (copy-local-file! local-file destination))
       (lambda ()
         (do-remote-process! `(rm -f ,destination)))))

    ;;; Ensure that the file has the given line somewhere in the file.
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

    ;;; Ensure that the remote FILE has the given CONTENTS, a list of strings.
    (define (file-has-contents file contents)
      (property
       (lambda ()
	 (set-remote-file-contents! file contents))))

    ;;; Ensure that FILENAME is owned by USER and GROUP. 
    (define (file-owned-by filename user group)
      (shell-command-property  `(chown ,(string-append user ":" group) ,filename)
                               (show #f "Changed ownership of " filename " to " user ":" group)))
  
    ;;; Ensure that the FILENAME has the chmod-compatible PERMISSIONS set.
    (define (file-permissions-set filename permissions)
      (shell-command-property `(chmod ,permissions ,filename)
                              (show #f "Changed permissions of " filename " to " permissions)))
   
    ;;; Ensure that FILENAME is owned by USER and GROUP, with all it's . 
    (define (directory-owned-by/rec name user group)
      (shell-command-property  `(chown ,(string-append user ":" group) -R ,name)
                               (show #f "Changed ownership of " name " to " user ":" group)))
  
    ;;; Ensure that the FILENAME has the chmod-compatible PERMISSIONS set.
    (define (directory-permissions-set/rec filename permissions)
      (shell-command-property `(chmod ,permissions -R ,filename)
                              (show #f "Changed permissions of " name " to " permissions)))

    ;;; Establish a symbolic link named LINKNAME that points to TARGET.
    (define (file-linked/symbolic target linkname)

      ;; TODO: check that the link actually points to the correct item
      (define (applied?)
        (do-remote-process `(test -L ,linkname)))

      (define (apply!)
        (do-remote-process! `(ln -s ,target ,linkname))
        (show #f "Symlinked " linkname " to point to " target))

      (define (unapply!)
        (do-remote-process! `(rm -rf ,name)))

      (property applied? apply! unapply!))

    ;;; Establish a hard link named LINKNAME that points to TARGET.
    (define (file-linked/hard target linkname)
      (shell-command-property `(ln ,target ,linkname)
                              (show #f "Hardlinked " linkname " to point to " target)))

    ))

