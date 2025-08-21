;;;; ultrawave.ssh : Tools to generate SSH configurations for inventories.
(define-library (ultrawave ssh)

  (export write-ssh-config
	  write-ssh-host-config
	  generate-ssh-config)

  (import (scheme base)
	  (scheme show)
	  (scheme write)
	  (scheme file)
	  (ultrawave wireguard)
	  (ultrawave host)
	  (ultrawave inventory))

  (begin

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

  ))

