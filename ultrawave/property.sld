
(define-library (ultrawave property)

  (export 
    property
    property-should-apply?
    property-apply!
    ensure-property!

    property-group
    performed-on-host)

  (import
   (scheme base)
   (scheme case-lambda)
   (ultrawave base))

  (begin 

   ;;; A property that can be applied or unapplied to a host.
   ;;;
   ;;; Properties consist of a few procedures, and a list of dependencies that this property
   ;;; requires.
   (define-record-type <property>
     (make-property applied? apply-fn unapply-fn dependencies host)
     property?

     ;; A predicate or #f, if not given then this property shall always 
     ;; be applied.
     (applied? property-applied-predicate)

     ;; A procedure that changes the host to have this property.
     (apply-fn property-apply-proc)

     ;; A procedure or #f that undoes any changes that `apply` would do.
     (unapply-fn property-unapply-proc)

     ;; List of properties which must be applied before this property is applied.
     (dependencies property-dependencies)

     ;; A pre-loaded host for which to execute a property upon.
     ;; Either a host? or #f.
     (host property-host property-set-host!))

   ;;; (property) -> property?
   ;;;
   ;;; Construct a new property.
   (define property
     (case-lambda
       ;; Basic properties just have an apply function
       ((apply-fn)
        (property #f apply-fn #f '()))

       ;; Undoable properties
       ((apply-fn unapply-fn)
        (property #f apply-fn unapply-fn '()))

       ;; Checkable properties
       ((applied? apply-fn unapply-fn)
        (property applied? apply-fn unapply-fn '()))

       ;; Default for 'host': #f
       ((applied? apply-fn unapply-fn dependencies)
        (make-property applied? apply-fn unapply-fn dependencies #f))))


   ;;; Return the property set up to always perform on the given host.
   (define (performed-on-host host property)
     (property-set-host! property host)
     property)


   ;;; Helper function for below to switch hosts if the property has the
   ;;; host set.
   (define (property-do-on-host property action)
     (if (property-host property)
         (parameterize ((current-remote-host (property-host property)))
           (action))
         (action)))

   ;;; (property-applied? property?) -> boolean?
   ;;;
   ;;; Check if this property is applied.
   (define (property-applied? property) 
     (unless (property-applied-predicate property)
             (error "property-applied?: cannot check if property applied if no check predicate exists"))
     (property-do-on-host property (property-applied-predicate property)))
   

   ;;; (property-should-apply? property?) -> boolean?
   ;;;
   ;;; Should this property be applied?
   (define (property-should-apply? property)
     (or (not (property-applied-predicate property))
         (not (property-applied? property))))


   ;;; (property-apply! property?)
   ;;;
   ;;; Apply this property to `(current-remote-host)`.
   (define (property-apply! property)
     (property-do-on-host property (property-apply-proc property)))


   ;;; (property-unapply! property?)
   ;;;
   ;;; Apply this property to `(current-remote-host)`.
   (define (property-unapply! property)
     (property-do-on-host (property-unapply-proc property)))


   ;;; (ensure-property! property?)
   ;;;
   ;;; Make sure that this property is enabled.
   (define (ensure-property! property)
     (for-each ensure-property! (property-dependencies property))
     (when (property-should-apply? property)
       (property-apply! property)))
  

   ;;; (prevent-property! property?)
   ;;;
   ;;; Make sure that this property is disabled.
   (define (prevent-property! property)
     (if (property-should-apply? property)
       (property-unapply! property)))

   
   ;;; (property-group (string? description) . (property? properties)) -> property?
   ;;;
   ;;; Create a property that depends on several properties, and then upon application
   ;;; will log the given description. Useful for naming groups of properties.
   (define (property-group description . properties)
     (property #f
               (lambda ()
                 (log/remote-host description))
               #f
               properties))))
