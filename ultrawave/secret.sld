(define-library (ultrawave secret)
  (export secret-set!
          secret-ref
          secret-remove!

          secret-storage
          
          pass-secret-storage)

  (import (scheme base)
          (scheme write)
          (gauche base)
          (gauche process))

  (begin
   (define-record-type <secret-storage>
     (secret-storage set!-procedure ref-procedure remove-procedure)
     secret-storage?
     (set!-procedure secret-storage-set!-procedure)
     (ref-procedure secret-storage-ref-procedure)
     (remove-procedure secret-storage-remove-procedure))
   
   (define (secret-set! storage name value)
     ((secret-storage-set!-procedure storage) name value))

   (define (secret-ref storage name)
     ((secret-storage-ref-procedure storage) name))
   
   (define (secret-remove! storage name)
     ((secret-storage-remove-procedure storage) name))
   
   (define pass-secret-storage
     (secret-storage

      ;; Set a password.
      (lambda (name value)
        (let* ((p (run-process `(pass add ,name)
                               :input :pipe))
               (in (process-input p)))
          ;; initial entry
          (display value in)
          (newline in)
          ;; confirm entry
          (display value in)
          (newline in)
          (process-wait p)))

      ;; Get a password.
      (lambda (name)
        (let* ((p (run-process `(pass show ,name)
                               :output :pipe
                               :error :null))
               (password (read-line (process-output p))))
          (process-wait p)
          (if (zero? (process-exit-status p))
            password
            #f)))
     
      ;; Remove a password.
      (lambda (name)
        (do-process! `(pass rm --force ,name)))))

   ))

