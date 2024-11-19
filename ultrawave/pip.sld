
(define-library (ultrawave pip)
  (export packages-installed)
  (import (scheme base)
          (scheme show)
          (ultrawave base)
          (ultrawave command))
  (begin

    (define (packages-installed . packages)
      (shell-command-property
       `(python3 -m pip install ,@packages)
       (show #f "Pip packages installed:" packages)))
   
   ))
