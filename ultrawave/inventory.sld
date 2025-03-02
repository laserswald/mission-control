
(define-library (ultrawave inventory)

  (export all-inventory
          inventory-clear!
          inventory-add!
          inventory-configure!
          inventory-configure!/threaded
          define-host)

  (import (scheme base)
          (gauche base)
          (scheme hash-table)
          (scheme comparator)
          (scheme show)
          (ultrawave base)
          (ultrawave host)
          (ultrawave command)
          (srfi 18))

  (begin
    (define all-inventory 
      (make-hash-table (make-default-comparator)))

    (define (inventory-clear!)
      (set! all-inventory 
            (make-hash-table (make-default-comparator))))

    (define (inventory-add! host configure!)
      (hash-table-set! all-inventory host configure!))

    (define (inventory-configure!)
      (hash-table-for-each (lambda (_ configure!)
                             (configure!))
       all-inventory))

    (define (reset-lines l)
      (define (csi n code)
        (write-u8 #x1B)
        (write-u8 #\[)
        (display n)
        (display code))
      ; Move cursor l lines up
      (csi l #\F)
      ; Erase in display everything from cursor on
      (csi 0 #\J))
             
    
    (define (inventory-configure!/threaded)
      (let ([threads '()])

        (define (make-worker host configure!)
          (make-thread (lambda ()
                         (guard (exn 
                                 ((command-exception? exn)
                                  (show (current-error-port)
                                        (command-exception-displayed exn)
                                        nl)
                                  #f)
                                 (else (show (current-error-port) exn nl)
                                       (report-error exn)
                                       #f))
                           (configure!)))
                       (host-nick host)))

        (define (join-worker! worker)
          (guard (exn ((terminated-thread-exception? exn)
                       (show #t "Worker thread " name " terminated." nl)
                       #f)
                      ((uncaught-exception? exn) 
                       (raise (uncaught-exception-reason exn)))
                      (else (report-error exn) #f))
            (thread-join! worker)))

        (define (add-worker! host configure!)
          (set! threads 
                (cons (make-worker host configure!)
                      threads)))

        (hash-table-for-each add-worker! all-inventory)
        (show #t threads nl)
        (for-each thread-start! threads)
        (show #t threads nl)
        (for-each join-worker! threads)))

    (define-syntax define-host
      (syntax-rules ()
        ((define-host %identifier (%user %address) %configure-identifier (%properties ...))
         (begin 
          (define %identifier
            (host %user %address (symbol->string '%identifier)))
          (define (%configure-identifier)
            (configure! (list %properties ...) %identifier))
          (inventory-add! %identifier %configure-identifier)))))))
   
   
