(import (scheme base)
        (ultrawave base)
        (ultrawave pacman)
        (ultrawave inventory)
        (ultrawave command)
        (ultrawave wireguard)
	(ultrawave network))

;; Reset the inventory every time we load this file.
(inventory-clear!)

(define dnsmasq-service (dnsmasq-dns-service "dnsmasq"))
(define pihole-ftl-service (dnsmasq-dns-service "pihole-FTL"))

;; Sol is my main internet-accessible host.
;;
;; Currently, it is a small VPS hosted by Vultr based in Atlanta.
;;
;; It is the current WireGuard hub, as well as the jump host for
;; the heavier weight services (mostly game services). 
(define-host sol
  ("root" "sol.lazr.space")
  configure-sol!

  ;; Sol is an Arch Linux installation, so we need to have those packages
  ;; updated whenever we can.
  (pacman:updated

   ;; We absolutely must have openssh installed, or we can't shell into it.
   (pacman:packages-installed "openssh")

   ;; Set up the WireGuard hub, since Sol is accessible via the internet.
   ;; This will relay VPN traffic from my other machines (possibly via the
   ;; internet) and allow connections between them all.
   (wireguard-setup/arch "hub")

   ;; Since Sol is internet-accessible, it gets the job of acquiring TLS
   ;; certificates from Let's Encrypt.
   ; certbot-enabled

   ;; Allow tunneling traffic from the internet through Sol to my VPN.
   ;; 
   ;; This lets me host more expensive services without paying a large recurring
   ;; fee.
   ip-forwarding-enabled

   ;; Tunnel the vanilla Minecraft server to Andromeda.
   (port-tunneled "10.1.0.1" 25565 "10.1.0.3")

   ;; Tunnel the Greeblecraft Minecraft server to Andromeda too.
   (port-tunneled "10.1.0.1" 25566 "10.1.0.3")
   (port-tunneled "10.1.0.1" 24454 "10.1.0.3") ; Simple Voice Chat

   ;; Enable web hosting. 
   lighttpd-enabled/arch

   ;; Enable calendar hosting via CalDAV.
   radicale-enabled

   ;; Enable the XMPP server for serving lazr.space with XMPP.
   prosody-enabled

   ;; Enable the ZNC IRC bouncer.
   znc-enabled

   ;; Sol is internet-facing, so it needs a little bit of hardening.
   internet-facing-properties/arch))

;; Andromeda is my "big" server that I have at home.
;;
;; Andromeda is so named because it should host a galaxy of services. Get it?
;;
;; Andromeda hosts game servers like Minecraft and Factorio as well as development
;; tools and pipelines like Laminar.
(define-host andromeda 
  ; ("root" "andromeda.home.arpa") 
  ("root" "192.168.1.3") 
  configure-andromeda!
  (
   ;; Update and upgrade all the packages to the latest stuff available.
   core-setup/debian

   ;; Connect Andromeda to the VPN.
   ;;
   ;; Very important, since traffic that goes from the internet to Andromeda
   ;; passes through the VPN in order to be used.
   (wireguard-setup/debian "andromeda")

   ; zeroconf-setup/debian

   ;; Guest users are allowed to take advantage of Andromeda's huge RAM
   ;; and disk.
   (guest-users-set-up guest-users)

   ;; The vanilla minecraft server lives in Andromeda.
   (minecraft-instance-enabled "vanilla")

   ;; As well as a Factorio server.
   (services-enabled "factorio-server")

   ; grocy-enabled

   ;;;
   ;;; WIP projects here.
   ;;;

   ;; The bird cam sends a live feed to Andromeda for viewing.
   bird-cam-receiver-enabled

   ; (accountabilly-enabled)
   (apt:packages-installed "mpc")))

#;(define-host vespa 
  ("root" "192.168.1.5")
  configure-vespa!
  (core-setup/debian
   zeroconf-setup/debian

   (wireguard-setup/debian "vespa")

   mpd-setup))

(define-host baked
  ("root" "baked.home.arpa")
  configure-baked!
  (core-setup/debian 
   (wireguard-setup/debian "baked")
   (dns-cname-registered pihole-ftl-service
                         "grocy.lazr.internal"
                         "andromeda.lazr.internal"))) 


;;; French-fry is an AWS EC2 instance used for small tasks and for cloud practice.

(define french-fry
  (host "admin" "french-fry" "french-fry" 'ssh-sudo))

(define (configure-french-fry!)
  (configure! (list core-setup/debian
                    ; (wireguard-setup/debian "french-fry")

                    ;; Enable the system checking script.
                    (system-monitor-enabled (current-secrets)))
              french-fry))
