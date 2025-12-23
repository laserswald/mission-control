;;;; Protocols for separating interface from implementation
(define-library (lazr protocol)
  (export
   define-protocol)

  (import (scheme base))

  (begin
    ;;; Define a group of procedures that implement an abstraction of functionality.
    ;;;
    ;;; (define-protocol <record-type-descriptor>
    ;;;   make-implementation recognizer?
    ;;;   (method-field (method implementation args...) method-accessor) ...)
    ;;;
    ;;; Defines a new type (the protocol type) with a constructor and recognizer,
    ;;; along with procedures that users of the abstraction will use.
    ;;;
    ;;; In the case of protocols with a single procedure, it's usually enough to
    ;;; dispense with the abstraction barrier and just use the procedure itself.
    ;;; For example, a `Functor` protocol may not be necessary since most types
    ;;; will define a single `map` procedure.
    ;;;
    ;;; Other examples include the R7RS comparator, etc.
    (define-syntax define-protocol
      (syntax-rules ()
       ((_ <protocol-type> construct recognize?
           (method-field (method-name impl method-args ...) method-accessor) ...)

        (begin
          ;; Protocols are represented as records, with each field of the record
          ;; storing the particular implementation of the method
          (define-record-type <protocol-type>
            (construct method-field ...)
            recognize?
            (method-field method-accessor) ...)

          ;; Each method takes the concrete implementation as the first argument
          (define (method-name impl method-args ...)
            (apply (method-accessor impl) (list method-args ...))) ...))))))

