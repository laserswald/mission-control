;;;; ultrawave host - hosts to apply properties to
(define-library (ultrawave host)

  (export host
          host?
          host-user
          host-name
          host-nick
          host-protocol
          host-package-manager

          show-host
          host-login-string
          host-alive?

          localhost
          with-local-host

          current-remote-host
          current-host-login-string)

  (import (scheme base)
          (scheme case-lambda)
          (scheme process-context)
          (scheme show)
          (scheme comparator)
          (scheme mapping))

  (begin

   ;;; A recognizer for host protocols.
   (define (host-protocol? x)
     (member '(ssh sudo) x))


   ;;; A computer to apply properties to.
   (define-record-type <host>
     (%host user
            name
            nick
            protocol
            package-manager
            extras
            pre-config-hook
            post-config-hook)

     host?

     ;; The username to execute commands as.
     (user host-user)

     ;; The domain names or IP addresses that the host can be
     ;; accessed by.
     (name host-name)

     ;; A human-readable nickname for the host.
     (nick host-nick)

     ;; What protocol should be used?
     (protocol host-protocol)

     ;; What kind of package manager is supported on this host?
     (package-manager host-package-manager)

     ;; Pre/post property information.
     (extras host-extras
             host-set-extras!)

     ;; Pre-configuration hook: list of procedures to be executed
     ;; before properties are configured.
     (pre-config-hook host-pre-config-hook
                      host-set-pre-config-hook!)

     ;; Post-configuration hook.
     (post-config-hook host-post-config-hook
                       host-set-pre-config-hook!))


   (define (make-hook) '())

   (define (hook-adjoin hook proc)
     (cons proc hook))

   (define (hook-run! hook)
     (for-each (lambda (p) (p)) hook))


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
        (host user name nick 'ssh))

       ((user name nick proto)
        (%host user name nick proto
               #f
               (mapping (make-default-comparator))
               (make-hook)
               (make-hook)))))


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


   ;;; (host-alive? host?) -> boolean?
   ;;;
   ;;; Returns true if the host is pingable.
   (define (host-alive? host)
     (do-process `(ping -c 1 ,(host-name host))))


   ;;; (host-extras-ref host? any?) -> any? | #f
   ;;;
   ;;; Look up an extra configuration parameter.
   (define (host-extras-ref host key)
     (mapping-ref/default (host-extras host) key #f))


   (define (host-extras-set! host key value)
     (host-set-extras! host (mapping-set (host-extras host) key value)))


   ;;; (host-extras-adjoin! host? any? any?) -> undefined
   ;;;
   ;;; Add an extra information parameter.
   (define (host-extras-adjoin! host key . items)
     (host-set-extras! host
                       (mapping-update
                        (host-extras host)
                        key
                        ;; updater
                        (lambda (old-value)
                          (set-adjoin old-value items))
                        ;; on failure
                        (lambda ()
                          (set (make-default-comparator))))))


   ;;; A host for the local machine.
   (define localhost
    (host (get-environment-variable "USER")
          "localhost"
          "localhost"
          'sudo))

   ;;;;
   ;;;; The current host parameter and associated procedures
   ;;;;

   ;;; Parameter for current host we are applying to.
   (define current-remote-host
     (make-parameter
      localhost
      (lambda (host)
        (if (host? host)
          host
          (error "current-remote-host: cannot be set to non-host value " host)))))

   ;;; (with-local-host body)
   ;;;
   ;;; Perform the body on the local machine.
   (define-syntax with-local-host
     (syntax-rules ()
       ((_ . body)
        (parameterize ((current-remote-host localhost))
          body))))

   ;;; (current-host-login-string) -> string?
   ;;;
   ;;; Get the login string for the current host.
   (define (current-host-login-string)
     (host-login-string (current-remote-host)))

   ))

