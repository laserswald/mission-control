(define-library (lazr hook)
  (export make-hook
	  hook-adjoin
	  hook-run!)

  (import (scheme base)
	  (scheme list))

  (begin
    (define (make-hook) (list))

    (define (hook-adjoin hook proc)
      (lset-adjoin eq? hook proc))

    (define (hook-run! hook . args)
      (for-each (lambda (p) (apply p args)) hook))

    ))
