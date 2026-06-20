(define-library (ultrawave log)

  (export log-callback
          current-severity-limit
          with-severity-limit
          with-debugging-log)

  (import (scheme base)
          (scheme show)
          (ultrawave host))

  (export send-log
          current-log-fields
          current-log-callback
          EMERGENCY ALERT CRITICAL ERROR WARNING NOTICE INFO DEBUG)
  (import (srfi 215))

  (begin

    (define current-severity-limit
      (make-parameter INFO))

    (define (with-severity-limit sev thunk)
      (parameterize ((current-severity-limit sev))
        (thunk)))

    (define (with-debugging-log thunk)
      (with-severity-limit DEBUG thunk))

    (define (as-severity-color sev fmt)
      (cond
        ((member sev (list EMERGENCY ALERT CRITICAL ERROR)) 
         (as-red fmt))
        ((= sev WARNING) (as-yellow fmt))
        ((= sev NOTICE) (as-green fmt))
        ((= sev INFO) (as-blue fmt))
        ((= sev DEBUG) (as-magenta fmt))
        (else (error "unknown severity" sev))))

    (define (log-callback fields)
      (let ((severity (cdr (assq 'SEVERITY fields))))
        (when (<= severity (current-severity-limit))
            (show #t
                  (as-severity-color severity (each "[" (cdr (assq 'HOST fields)) "]"))
                  " "
                  (displayed (cdr (assq 'MESSAGE fields)))
                  nl))))))
