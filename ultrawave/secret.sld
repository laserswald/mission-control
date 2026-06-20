;;;; ultrawave.secret : access secret data

(define-library (ultrawave secret)
  (export secret-set! secret-ref secret-remove!
          secret-storage
          pass-secret-storage
          current-secrets)

  (import (scheme base)
          (scheme write)
          (gauche base)
          (gauche process))

  (begin
    ;;; Abstraction of a method of storing and retrieving secret data.
    ;;;
    ;;; This abstraction is more or less equivalent to a key-value association
    ;;; usually indexed by strings, though there is no enforcement of this.
    (define-record-type <secret-storage>
      (secret-storage set!-procedure ref-procedure remove-procedure)
      secret-storage?
      (set!-procedure secret-storage-set!-procedure)
      (ref-procedure secret-storage-ref-procedure)
      (remove-procedure secret-storage-remove-procedure))

    ;;; Set the secret with the NAME to the VALUE in the STORAGE.
    (define (secret-set! storage name value)
      ((secret-storage-set!-procedure storage) name value))

    ;;; Retrieve the secret with the NAME in STORAGE.
    (define (secret-ref storage name)
      ((secret-storage-ref-procedure storage) name))

    ;;; Delete the secret with the NAME in the STORAGE.
    (define (secret-remove! storage name)
      ((secret-storage-remove-procedure storage) name))


    ;;; An implementation of a secret-storage that uses the local
    ;;; password store (see pass)
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

    (define current-secrets
      (make-parameter #f
                      (lambda (maybe-secrets)
                        (if (or (equal? #f maybe-secrets)
                                (secret-storage? maybe-secrets))
                            maybe-secrets
                            (error "current-secrets: attempted to register non-secret-storage " maybe-secrets)))))))

