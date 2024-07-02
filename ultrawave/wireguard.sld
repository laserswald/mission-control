
#|
;;
;; Ensure that a wireguard private key exists
;;
(define (wireguard-private-key-generated secret-storage name)
  (property 
   (lambda ()
     (secret-ref secret-storage name))

   (lambda ()
     (log/remote-host "Generating new WireGuard keypair.")
     (secret-set! secret-storage 
                  name
                  (process->string '(wg genkey))))

   (lambda ()
     (secret-remove! secret-storage name))

   (list 
    (apt:packages-installed "wireguard" "wireguard-tools"))))

(define (wireguard-public-key-generated secret-storage private-key-name)
  ())

     (do-remote-process! `(wg pubkey < ,private > ,public)))
(define (wireguard-keys-installed host)
  (property
   (lambda () 
     (with-local-host))
   ()
   ()
   (list (wireguard-keys-generated ))))

(define (directory-exists! name)
  (property (lambda ())))

(define (wireguard-keys-generated private public)
  (with-local-host
    (directory-exists! "wireguard"))

  (file-copied-from public (string-append "wireguard/"
                                          (host-nick (current-remote-host))
                                          ".pubkey")))

(define (wireguard-setup)
  (apt:packages-installed "wireguard" "wireguard-tools")
  (wireguard-keys-generated "/etc/wireguard/privatekey"
                            "/etc/wireguard/publickey"))
|#
