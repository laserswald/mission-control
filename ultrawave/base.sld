(define-library (ultrawave base)

  (export host
          host?
          host-user
          host-name
          host-nick
          host-protocol
          show-host

          current-remote-host
          current-host-login-string
          localhost
          
          property
          property-should-apply?
          property-apply!
          ensure-property!
          shell-command-property

          log/remote-host
          do-remote-process
          do-remote-process!
          configure!)

  (import (scheme base)
          (scheme process-context)
          (scheme show)
          (gauche base)
          (gauche process))

  (begin
   
   (define (host-protocol? x)
     (member '(ssh sudo) x))


   ;;; A computer to apply properties to.
   (define-record-type <host>
     (%host user name nick protocol)
     host?

     ;; The username to execute commands as.
     (user host-user)

     ;; The domain name or IP address that the host can be 
     ;; accessed by.
     (name host-name)

     ;; A human-readable nickname for the host.
     (nick host-nick)
     
     ;; What protocol should be used?
     (protocol host-protocol)
     
     ;; What kind of package manager is supported on this host?
     (package-manager host-package-manager))


   ;;; (host [(string? user)] 
   ;;;       (string? hostname) [(string? nickname)]) -> host?
   ;;;
   ;;; Construct a host.
   (define host
     (case-lambda 
       ((name)
        (host "root" name))

       ((user name)
        (host user name name))

       ((user name nick)
        (%host user name nick 'ssh))
       
       ((user name nick proto)
        (%host user name nick proto))))


   ;;; A host for the local machine.
   (define localhost 
    (host (get-environment-variable "USER")
          "localhost"
          "localhost"
          'sudo))


   ;;; (show-host host?)
   ;;;
   ;;; Display a host.
   (define (show-host host)
     (show #t 
           "<host '"
           (host-nick host)
           "' "
           (host-protocol host)
           " "
           (host-user host)
           "@"
           (host-name host)
           ">"))

   
   ;;; (host-login-string host?) -> string?
   ;;;
   ;;; Get the SSH-style login string for this host.
   (define (host-login-string host)
     (string-append (host-user host) "@" (host-name host)))


   ;;; Parameter for current host we are applying to.
   (define current-remote-host
     (make-parameter 
      localhost
      (lambda (host)
        (if (host? host) 
          host 
          (error "current-remote-host: cannot be set to non-host value " host)))))


   ;;; (current-host-login-string) -> string?
   ;;;
   ;;; Get the login string for the current host.
   (define (current-host-login-string)
     (host-login-string (current-remote-host)))


   ;;; (with-local-host body)
   ;;;
   ;;; Perform the body on the local machine.
   (define-syntax with-local-host
     (syntax-rules ()
       ((_ . body)
        (parameterize ((current-remote-host localhost))
          body))))


   ;;; A property that can be applied or unapplied to a host.
   ;;;
   ;;; Properties consist of a few procedures, and a list of dependencies that this property
   ;;; requires.
   (define-record-type <property>
     (property applied? apply-fn unapply-fn dependencies)
     property?

     ;; A predicate or #f, if not given then this property shall always 
     ;; be applied.
     (applied? property-applied-predicate)

     ;; A procedure that changes the host to have this property.
     (apply-fn property-apply-proc)

     ;; A procedure or #f that undoes any changes that `apply` would do.
     (unapply-fn property-unapply-proc)

     ;; Properties which must be applied before this property is applied.
     (dependencies property-dependencies))


   ;;; (property-applied? property?) -> boolean?
   ;;;
   ;;; Check if this property is applied.
   (define (property-applied? property) 
     (unless (property-applied-predicate property)
             (error "property-applied?: cannot check if property applied if no check predicate exists"))
     ((property-applied-predicate property)))
   

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
     ((property-apply-proc property)))


   ;;; (property-unapply! property?)
   ;;;
   ;;; Apply this property to `(current-remote-host)`.
   (define (property-unapply! property)
     ((property-unapply-proc property)))


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
   
   
   ;;; (shell-command-property (list? command) (string? description)) -> property?
   ;;;
   ;;; Create a property that will always run the `command` and then log the 
   ;;; given description.
   (define (shell-command-property command description)
     (property
      #f
      (lambda ()
        (do-remote-process! command)
        (log/remote-host description))
      #f
      '()))


   ;;; (property-group (string? description) . (property? properties)) -> property?
   ;;;
   ;;; Create a property that depends on several properties, and then upon application
   ;;; will log the given description. Useful for naming groups of properties.
   (define (property-group description . properties)
     (property #f
               (lambda ()
                 (log/remote-host description))
               (lambda ())
               properties))

   (define (log/remote-host . message)
     (show #t 
           (as-green "[" (host-nick (current-remote-host)) "]")
           " "
           (joined displayed message " ")
           nl))
   
   (define (protocol-command protocol command)
     (case protocol
      ((ssh)
       (append `(ssh ,(current-host-login-string)) 
               command))
      ((sudo)
       (append `(sudo)
               command))))

   (define (do-remote-process command)
     (do-process (protocol-command (host-protocol (current-remote-host)) command)))

   (define (do-remote-process! command)
     (do-process! (protocol-command (host-protocol (current-remote-host)) command)))

   (define (configure! configuration host)
     (parameterize ((current-remote-host host)) 
       (for-each (lambda (property)
                   (ensure-property! property))
                 configuration)))
   
  ))

