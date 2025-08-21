(import (scheme base)
        (ultrawave base)
        (ultrawave pacman)
        (ultrawave inventory)
        (ultrawave command)
        (ultrawave wireguard)
	(ultrawave network))

(inventory-clear!)

(define dnsmasq-service (dnsmasq-dns-service "dnsmasq"))
(define pihole-ftl-service (dnsmasq-dns-service "pihole-FTL"))

(define-host sol
  ("root" "sol.lazr.space")
  configure-sol!
  (; (core-setup)
   pacman:updated
   (pacman:packages-installed "openssh")
   
   ; certbot-enabled
   ; (minecraft-enabled "vanilla")
   ip-forwarding-enabled

   ;accountabilly-enabled

   ;; Vanilla minecraft
   (port-tunneled "10.1.0.1" 25565 "10.1.0.3")

   ;; Greeblecraft
   (port-tunneled "10.1.0.1" 25566 "10.1.0.3")
   (port-tunneled "10.1.0.1" 24454 "10.1.0.3") ; Simple Voice Chat

   lighttpd-enabled/arch
   prosody-enabled
   radicale-enabled
   znc-enabled
   internet-facing-properties/arch))
 
(define-host andromeda 
  ; ("root" "andromeda.home.arpa") 
  ("root" "192.168.1.3") 
  configure-andromeda!
  (core-setup/debian
   ; zeroconf-setup/debian
   
   (guest-users-set-up guest-users)

   bird-cam-receiver-enabled
   
   ; grocy-enabled

   (minecraft-instance-enabled "vanilla")

   (services-enabled "factorio-server")

   ; (accountabilly-enabled)
   (apt:packages-installed "mpc")))

(define-host vespa 
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

