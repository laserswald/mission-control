(define-library (ultrawave command)

  (export
   process->string
   process->string/remote
   process-transform
   do-remote-process
   do-remote-process!
   shell-command-property

   command-exception
   command-exception?
   command-exception-displayed)

  (import (scheme base)
          (scheme show)
          (gauche base)
          (gauche process)
          (ultrawave base)
          (ultrawave property))

  (begin

    (define (protocol-command protocol command)
      (case protocol
       ((ssh)
        (append `(ssh ,(current-host-login-string))
                command))
       ((sudo)
        (append `(sudo)
                command))
       ((ssh-sudo)
        (append `(ssh ,(current-host-login-string) sudo)
                command))
       (else
        (error "protocol-command: no such protocol" protocol))))

    (define (process->string command+args)
      (let* ([p (run-process command+args
                            :redirects '((> 1 out)))]
             [result (port->string (process-output p 'out))])
        (process-wait p)
        result))

    (define (process-transform value command+args)
      (let* ([p (run-process command+args
                             :redirects `((<< 0 ,value) (> 1 out)))]
             [result (port->string (process-output p 'out))])
        (process-wait p)
        result))

    (define-record-type <command-exception>
        (command-exception host command retcode stderr)
        command-exception?
      (host command-exception-host)
      (command command-exception-command)
      (retcode command-exception-retcode)
      (stderr command-exception-stderr))

    (define (command-exception-displayed ce)
      (each
        (joined displayed
                (list
                  (as-red "[" (host-nick (command-exception-host ce)) "]")
                  (command-exception-command ce)
                  "failed with error code"
                  (command-exception-retcode ce))
                " ")
        nl
        (as-yellow (command-exception-stderr ce))))

    (define (process->string/remote command)
      (process->string (protocol-command (host-protocol (current-remote-host)))))

    (define (do-remote-process command)
      (do-process (protocol-command (host-protocol (current-remote-host)) command)))

    (define (do-remote-process! command)
      (let* ([p (run-process (protocol-command (host-protocol (current-remote-host)) command)
                             :redirects `((>& 2 1) (> 1 out)))]
             [output (port->string (process-output p 'out))])
        (process-wait p)
        (if (not (= 0 (process-exit-status p)))
            (raise (command-exception (current-remote-host)
                                      command
                                      (process-exit-status p)
                                      output))
            #t)))

    ;;; (shell-command-property (list? command) (string? description)) -> property?
    ;;;
    ;;; Create a property that will always run the `command` and then log the
    ;;; given description.
    (define (shell-command-property command description)
      (property
       (lambda ()
         (do-remote-process! command)
         (log/remote-host description))))))
