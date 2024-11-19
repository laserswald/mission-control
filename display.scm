
(import (scheme base)
        (scheme write)
        (scheme show)
        (srfi 18))

(define (csi n code)
  (write-u8 #x1B)
  (write-char #\[)
  (display n)
  (write-char code))

(define (cursor-previous-line n) (csi n #\F))

(define (erase-in-display what)
  (csi
   (case what
     ((cursor-to-end) 0)
     ((cursor-to-beginning) 1)
     ((all) 2)
     ((all-and-scrollback) 3)
     (else (error "erase-in-display: Unrecognized parameter: " what)))
   #\J))

(define (erase-in-line what)
  (csi
   (case what
     ((cursor-to-end) 0)
     ((cursor-to-beginning) 1)
     ((all) 2)
     (else (error "erase-in-line: Unrecognized parameter: " what)))
   #\K))

(define (reset-lines n)
  (do ((i 0 (+ i 1)))
      ((= i n) #t)
    (cursor-previous-line n)
    (erase-in-line 'all)))

(define (do-times n proc)
  (do ((i 0 (+ i 1)))
      ((= i n) #t)
    (proc i)))

(define (test-counter)
  (newline)
  (do-times 10
            (lambda (i)
              (reset-lines 1)
              (show #t (as-yellow i) nl)
              (thread-sleep! 1))))
