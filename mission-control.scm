
(import (scheme base)
        (scheme show)
        (scheme hash-table)
        (scheme comparator)

        (gauche base)
        (gauche process)

        (ultrawave base)
	(ultrawave host)
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

(define wireguard-service-peers
  (names->peers "10.1.0." wireguard-service-names))
        
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
        "colton"
        "apk"))
        

(define storage-users
  (list "ben" "jules" "miriam" "megan" "gina" "robin"))

(define guest-users
  (list "neeasade" "apk" "chloeh"))

(define wireguard-peers
  (append wireguard-service-peers
          (names->peers "10.1.1." wireguard-user-names)))

(define lazr-internal-vpn
  (wireguard-network (car wireguard-peers) ;; Should be Sol
                     (cdr wireguard-peers)))

(include "units/core.scm")
(include "units/users.scm")
(include "services.scm")
(include "inventory.scm")

(define (write-ssh-config hosts)
  (show #t "# Generated file, do not edit!" nl)
  (for-each write-ssh-host-config hosts))

(define (write-ssh-host-config host)
  (show #t
	"Host " (wireguard-peer-name host) nl
	"  HostName " (wireguard-peer-ip-address host) nl
	"  User lazr"nl
	nl))

(define (generate-ssh-config hosts filename)
  (with-output-to-file filename
    (lambda ()
      (write-ssh-config hosts))))

(define (lazr/generate-ssh-config)
  (generate-ssh-config wireguard-service-peers
		       "lazr-vpn.conf"))

(define (configure-all!)
  (wireguard-network-generate-configs lazr-internal-vpn)
  (inventory-configure!/threaded))

