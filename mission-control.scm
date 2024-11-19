
(import (scheme base)
        (scheme show)
        (scheme hash-table)
        (scheme comparator)

        (gauche base)
        (gauche process)

        (ultrawave base)
        (ultrawave user)
        (ultrawave wireguard)
        (ultrawave filesystem)
        (prefix (ultrawave apt) apt:)
        (prefix (ultrawave pip) pip:)
        (prefix (ultrawave pacman) pacman:)
        (ultrawave systemd)
        (ultrawave secret)
        (ultrawave container)
        (ultrawave property))

;;; Generate wireguard peers.

(define (names->peers prefix names)
  (let ((ip-last 1))
    (map (lambda (name)
           (let ((peer (wireguard-peer name (string-append prefix (number->string ip-last))))) 
             (set! ip-last (+ 1 ip-last))
             peer))
         names)))

(define wireguard-service-names
  (list "sol"
        "sirius"
        "andromeda"
        "baked"
        "vespa"))
        
(define wireguard-user-names
  (list "ben-phone"
        "ben-laptop"
        "julia-phone"
        "julia-laptop"
        "gina"
        "robin"
        "miriam"
        "chloe"
        "nathan"
        "megan"
        "victoria"
        "colton"))

(define storage-users
  (list "ben" "jules" "miriam" "megan" "gina" "robin"))

(define wireguard-peers
  (append (names->peers "10.1.0." wireguard-service-names)
          (names->peers "10.1.1." wireguard-user-names)))

(define lazr-internal-vpn
  (wireguard-network (car wireguard-peers) ;; Should be Sol
                     (cdr wireguard-peers)))

         
(define (users-set-up secret-storage)
  (property-group "Users set up."
    (user-exists "lazr")
    #;(user-password-generated "lazr" secret-storage)))

(define (package-service-enabled/pacman package)
  (property-group 
   (show #f package " installed and enabled.")
   (pacman:packages-installed package)
   (services-enabled package)))

(define (package-service-enabled/apt package)
  (property-group 
   (show #f package " installed and enabled.")
   (apt:packages-installed package)
   (services-enabled package)))

(define core-setup/arch
  (property-group "Core set up for Arch system."
    (users-set-up pass-secret-storage)
    pacman:updated
    (pacman:packages-installed "tmux" "zsh")))

(define core-setup/debian
  (property-group "Core set up for Debian system."
    (users-set-up pass-secret-storage)
    apt:updated
    apt:upgraded
    apt:cleaned
    (apt:packages-installed "tmux" "zsh" "python3-pip")))
   
(include "services.scm")
(include "inventory.scm")

(define (configure-wireguard-registration!)
  (values))

(define (install-key! host)
  (do-process! `(ssh-copy-id ,(string-append "lazr@" (host-name host)))))

(define (install-keys! hosts)
  (for-each install-key! hosts))

(define (configure-all!)
  (wireguard-network-generate-configs lazr-internal-vpn)
  (inventory-configure!/threaded)
  (configure-wireguard-registration!))
