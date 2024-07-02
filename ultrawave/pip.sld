
(define-library (ultrawave pip)
  (export packages-installed)
  (import (scheme base) (ultrawave base) (scheme show))
  (begin

    (define (packages-installed . packages)
      (shell-command-property
       `(python3 -m pip install --break-system-packages ,@packages)
       (show #f "Pip packages installed:" packages)))
   
   ))
