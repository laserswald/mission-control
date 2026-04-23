
(import (scheme base)
        (scheme file)
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

(current-secrets pass-secret-storage)

(include "network.scm")
(include "units/core.scm")
(include "units/users.scm")
(include "services.scm")
(include "hosts.scm")

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
		       "lazr-space.conf"))

(define (configure-all!)
  (wireguard-network-generate-configs lazr-internal-vpn)
  (inventory-configure!/threaded))

