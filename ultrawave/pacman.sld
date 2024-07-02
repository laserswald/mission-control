(define-library (ultrawave pacman)
  (export packages-installed
          updated)
  (import (scheme base)
          (scheme list)
          (scheme show)
          (ultrawave base))
  (begin

   (define updated
     (shell-command-property 
      '(pacman --quiet --sync --refresh --noconfirm --sysupgrade)
      "Pacman packages updated."))

   (define (packages-installed . names)
     (property 
      ;; check
      (lambda ()
        (do-remote-process `(pacman --query --quiet ,@names >/dev/null)))
      ;; install
      (lambda ()
        (do-remote-process! `(pacman --quiet --sync --refresh --noconfirm ,@names)))
      ;; remove
      (lambda ()
        (do-remote-process! `(pacman --quiet --remove ,@names)))
      '()))

  ))
