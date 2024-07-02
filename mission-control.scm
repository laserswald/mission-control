
(import (scheme base)
        (scheme show)
        (gauche base)
        (gauche process)
        (ultrawave base)
        (ultrawave user)
        (ultrawave filesystem)
        (prefix (ultrawave apt) apt:)
        (prefix (ultrawave pip) pip:)
        (prefix (ultrawave pacman) pacman:)
        (ultrawave systemd)
        (ultrawave secret))

(define-syntax define-host
  (syntax-rules ()
    ((define-host %identifier (%user %address) %configure-identifier (%properties ...))
     (begin 
      (define %identifier
        (host %user %address (symbol->string '%identifier)))
      (define %configure-identifier
        (lambda ()
          (configure! (list %properties ...) %identifier)))))))
;;
;; Inventory of all my systems.
;;

(define vespa
  (host "root" "192.168.1.5" "vespa"))

(define-host andromeda ("root" "andromeda.lazr.lan") configure-andromeda!
  (core-setup/debian
   zeroconf-setup/debian
   (apt:packages-installed "mpc")))

(define baked 
  (host "root" "baked.lazr.lan" "baked"))

(define sol
  (host "root" "sol.lazr.space" "sol"))

(define sirius
  (host "root" "sirius.vm.tornadovps.net" "sirius"))

(define inventory
  (list vespa andromeda baked sol))

(define (host-alive? host)
  (do-process `(ping -c 1 ,(host-name host))))

(define (users-set-up secret-storage)
  (property-group "Users set up."
    (user-exists "lazr")
    (user-password-generated "lazr" secret-storage)))

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
    (apt:packages-installed "tmux" "zsh" "python3-pip")
    ;(wireguard-setup)
    ))

(define zeroconf-setup/debian
  (property-group "Set up zeroconf support."
    (package-service-enabled/apt "avahi-daemon")
    (package-service-enabled/apt "wsdd")))

(define mpd-setup
  (property-group "MPD service set up."
   (apt:packages-installed
    "mopidy"
    "mopidy-mpd"
    "mpc"
    "ncmpcpp"
    "gstreamer1.0-tools")

   (pip:packages-installed
    "Mopidy-Spotify"
    "Mopidy-Iris")

   (services-enabled "mopidy")))

(define fail2ban-enabled (package-service-enabled/pacman "fail2ban"))
(define lighttpd-enabled (package-service-enabled/pacman "lighttpd"))
(define prosody-enabled (package-service-enabled/pacman "prosody"))
(define radicale-enabled (package-service-enabled/pacman "radicale"))
(define znc-enabled (package-service-enabled/pacman "znc"))

(define internet-facing-properties
  (list fail2ban-enabled))

(define (configure-baked!)
  (configure! (list core-setup/debian) baked))

(define (configure-vespa!)
  (configure! 
   (list
    core-setup/debian
    (mpd-setup))
   vespa))

(define (configure-sol!)
  (configure! 
   (append (list
            ; (core-setup)
            pacman:updated
            (pacman:packages-installed "openssh")
            
            ; certbot-enabled
            ; (minecraft-enabled "vanilla")

            lighttpd-enabled
            prosody-enabled
            radicale-enabled
            znc-enabled
            )
           internet-facing-properties)
   sol))

(define (configure-sirius!)
  (configure! (list
               pacman:updated
               (pacman:packages-installed "openssh"))
              sirius))

(define (configure-wireguard-registration!)
  (values))

(define (configure-each configuration hosts)
  (for-each (lambda (host)
              (configure! configuration host))
            hosts))

(define (install-key! host)
  (do-process! `(ssh-copy-id ,(string-append "lazr@" (host-name host)))))

(define (install-keys! hosts)
  (for-each install-key! hosts))

(define (configure-all!)
  (configure-baked!)
  (configure-andromeda!)
  (configure-vespa!)
  (configure-sol!)
  (configure-wireguard-registration!))
