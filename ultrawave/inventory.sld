
(define-library (ultrawave inventory)

  (export all-inventory
          inventory-clear
          inventory-add!
          inventory-configure!
          inventory-configure!/threaded
          define-host)

  (import (scheme base)
          (scheme hash-table)
          (scheme comparator)
          (ultrawave base)
          (ultrawave host)
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
      (let ((threads '()))
        (hash-table-for-each (lambda (_ configure!)
                               (let ((worker (thread-start! (make-thread configure!))))
                                 (set! threads (cons worker threads))))
                             all-inventory)
        (for-each thread-join! threads)))

    (define-syntax define-host
      (syntax-rules ()
        ((define-host %identifier (%user %address) %configure-identifier (%properties ...))
         (begin 
          (define %identifier
            (host %user %address (symbol->string '%identifier)))
          (define (%configure-identifier)
            (configure! (list %properties ...) %identifier))
          (inventory-add! %identifier %configure-identifier)))))))
   
   
