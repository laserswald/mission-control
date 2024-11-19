
(define-library (ultrawave wireguard)

  (export wireguard-setup/debian
          wireguard-setup/arch

          wireguard-peer
          wireguard-peer?
          wireguard-peer-name
          wireguard-peer-address
          wireguard-peer-private-key

          wireguard-peer-displayed

          show-wireguard-peer
          wireguard-peer-client-config
          wireguard-peer-hub-config

          wireguard-network
          wireguard-network-server
          wireguard-network-clients
          wireguard-network-generate-configs)
          
          

  (import (scheme base)
          (scheme text)
          (scheme file)
          (scheme show)
          (ultrawave base)
          (ultrawave command)
          (ultrawave filesystem)
          (ultrawave systemd)
          (prefix (ultrawave apt) apt:)
          (prefix (ultrawave pacman) pacman:)
          (file util))

  (begin

    (define (generate-key)
      (process->string '(wg genkey)))

    (define (trim-key key)
      (textual->string (textual-trim-both key)))

    (define (get-private-key name)
      (let ((private-key-file (string-append "wireguard/" name)))
        (if (file-exists? private-key-file)

            (trim-key (file->string private-key-file))

            (let ((key (trim-key (generate-key))))
              (show #t "wireguard: Generated new key for " name nl)
              (string->file private-key-file key)
              key))))

    (define (generate-public-key private-key)
      (trim-key (process-transform private-key '(wg pubkey))))

    ;;; Wireguard peer
    (define-record-type <wireguard-peer>
        (%wireguard-peer name ip-address private-key)
        wireguard-peer?
      (name wireguard-peer-name)
      (ip-address wireguard-peer-ip-address)
      (private-key wireguard-peer-private-key))

    (define (wireguard-peer name ip-address)
      (%wireguard-peer name
                       ip-address
                       (get-private-key name)))

    (define (wireguard-peer-public-key peer)
      (generate-public-key (wireguard-peer-private-key peer)))

    (define (wireguard-peer-displayed peer)
      (each "#<wireguard-peer " (wireguard-peer-name peer)
            " " (wireguard-peer-ip-address peer)
            " '" (wireguard-peer-private-key peer) "'"
            ">"))

    (define (show-wireguard-peer peer)
      (show #t (wireguard-peer-displayed peer) nl))

    (define (wireguard-peer-client-config peer hub)
      (show #t
            "[Interface]" nl
            "PrivateKey = " (wireguard-peer-private-key peer) nl
            "Address = " (wireguard-peer-ip-address peer) "/32" nl
            nl
            "[Peer]" nl
            "PublicKey = " (wireguard-peer-public-key hub) nl
            "AllowedIPs = 10.1.0.0/24, 10.1.1.0/24" nl
            "PersistentKeepalive = 25" nl
            "Endpoint = lazr.space:51820" nl))

    ;; Output the fragment of configuration needed for the WireGuard hub.
    (define (wireguard-peer-hub-config peer)
      (show #t
            "[Peer]" nl
            "# Name = " (wireguard-peer-name peer) nl
            "PublicKey = " (wireguard-peer-public-key peer) nl
            "AllowedIPs = " (wireguard-peer-ip-address peer) "/32" nl))


    ;;; Generate and install wireguard public and private keys.
    ;;;
    ;;; This can get quite involved. The end state that we want is
    ;;; a wg-quick interface set up on each member.
    ;;;
    ;;; One member is designated the "server" and will receive connection
    ;;; requests and traffic. All other members must know about the server, specifically
    ;;; how it can be accessed.

    (define-record-type <wireguard-network>
      (wireguard-network server clients)
      wireguard-network?

      ;; Server configuration of type peer?
      (server wireguard-network-server)

      ;; List of peers that are the other clients in the system
      (clients wireguard-network-clients)

      ;; Internal address used for routing DNS queries.
      (dns-addr wireguard-network-dns-address)

      (listen-port wireguard-network-listen-port))


    (define (wireguard-network-generate-configs network)
      ;; Generate the configuration for each peer.
      (define (generate-peer-files hub peer)
        (let ([peer-conf (string-append "wireguard/" (wireguard-peer-name peer) ".conf")])
          (show #t "Generating peer config file " peer-conf nl)
          (with-output-to-file peer-conf
            (lambda () (wireguard-peer-client-config peer hub)))))

      ;; Generate the base configuration for the hub.
      (define (generate-hub-file hub clients)
        (show #t "Generating hub config file for " (wireguard-peer-displayed hub) nl)
        (with-output-to-file "wireguard/hub.conf"
          (lambda ()
            (show #t
                  "[Interface]" nl
                  "ListenPort = 51820" nl
                  "Address = " (wireguard-peer-ip-address hub) "/16" nl
                  "PrivateKey = " (wireguard-peer-private-key hub) nl)
            (for-each wireguard-peer-hub-config
                      clients))))

      (let ((hub (wireguard-network-server network))
            (clients (wireguard-network-clients network)))  
        (for-each (lambda (peer)
                    (generate-peer-files hub peer))
                  clients)
        (generate-hub-file hub clients)))
                  

    (define (wireguard-setup/arch name)
      (property-group
       "Set up wireguard peer."
       (pacman:packages-installed "wireguard-tools")
       (file-copied-to (string-append "wireguard/" name ".conf")
                       "/etc/wireguard/wg0.conf")
       (services-enabled "wg-quick@wg0")
       (services-restarted "wg-quick@wg0")))

    (define (wireguard-setup/debian name)
      (property-group
       "Set up wireguard peer."
       (apt:packages-installed "wireguard" "wireguard-tools")
       (file-copied-to (string-append "wireguard/" name ".conf")
                       "/etc/wireguard/wg0.conf")
       (services-enabled "wg-quick@wg0")
       (services-restarted "wg-quick@wg0")))))

