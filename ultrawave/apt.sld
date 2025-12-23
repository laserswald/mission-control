
(define-library (ultrawave apt)
  (export packages-installed
          updated upgraded cleaned)
  (import (scheme base)
          (scheme list)
          (scheme show)
          (ultrawave base)
          (ultrawave command))
  (begin
    (define updated
      (shell-command-property
       '(apt-get update --yes)
       "Apt package listing brought up to date."))

    (define upgraded
      (shell-command-property
       '(apt-get upgrade --yes)
       "Apt packages upgraded."))

    (define cleaned
      (shell-command-property
       '(apt-get autoremove --purge --quiet --yes)
       "Cleaned unused apt packages."))

    (define (packages-installed . names)
      (shell-command-property
       `(apt-get install --quiet --yes ,@names)
       (show #f "Packages installed: " names)))))

