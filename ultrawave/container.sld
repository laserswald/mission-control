(define-library (ultrawave container)
  (export image-saved
          image-loaded
          image-pulled
          local-image-copied)

  (import (scheme base)
          (scheme show)
          (ultrawave base)
          (ultrawave command)
          (ultrawave host)
          (ultrawave property)
          (ultrawave filesystem))

  (begin
    (define (image-pulled name)
      (shell-command-property
       `(podman pull ,name)
       (show #f "Pulled container image " name)))

    (define (image-loaded file)
      (property
        (lambda ()
          (do-remote-process! `(podman load --input ,file))
          (do-remote-process! `(rm ,file)))))

    (define (image-saved image-name file)
      (property (lambda ()
                  (do-remote-process! `(test -f ,file)))
                (lambda ()
                  (do-remote-process! `(podman save --output ,file ,image-name)))
                (lambda ()
                  (do-remote-process! `(rm -f ,file)))))

    (define (local-image-copied image-name)
      (define image-file
        (string-map (lambda (c)
                      (cond
                       ((or (char=? c #\/)
                            (char=? c #\:))
                        #\-)
                       (else c)))
                    image-name))
      (property-group (string-append "Copied " image-name " to remote host.")
        (performed-on-host localhost
         (image-saved image-name image-file))
        (file-copied-to image-file image-file)
        (image-loaded image-file)))))
