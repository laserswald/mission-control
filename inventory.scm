(import (scheme base)
        (ultrawave base)
        (ultrawave pacman)
        (ultrawave inventory)
        (ultrawave command)
        (ultrawave wireguard))

(define ip-forwarding-enabled
  (shell-command-property
   `(sysctl net.ipv4.ip_forward=1)
   "Enabled IP forwarding."))

(inventory-clear!)

(define-host sol
  ("root" "sol.lazr.space")
  configure-sol!
  (; (core-setup)
   pacman:updated
   (pacman:packages-installed "openssh")
   
   ; certbot-enabled
   ; (minecraft-enabled "vanilla")
   (wireguard-setup/arch "hub")
   ip-forwarding-enabled

   lighttpd-enabled/arch
   prosody-enabled
   radicale-enabled
   znc-enabled
   internet-facing-properties/arch))
 

#;(define-host sirius
    ("root" "sirius.vm.tornadovps.net")
    configure-sirius!
    (pacman:updated
     (pacman:packages-installed "openssh")
     (pacman:packages-installed "crun" "podman")
     (wireguard-setup/arch "sirius")
     internet-facing-properties/arch))

(define-host andromeda 
  ("root" "andromeda.lazr.internal") 
  configure-andromeda!
  (core-setup/debian
   ; zeroconf-setup/debian
   
   (guest-users-set-up guest-users)

   lighttpd-enabled/debian
   (wireguard-setup/debian "andromeda")
   
   grocy-enabled

   (services-enabled "dw20-server"
                     "factorio-server")

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
  ("root" "192.168.1.2")
  configure-baked!
  (core-setup/debian 

   (wireguard-setup/debian "baked")

   (dns-cname-registered "grocy.lazr.internal"
                         "andromeda.lazr.internal")

   #;zeroconf-setup/debian))
   
