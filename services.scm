(include "units/lighttpd.scm")
(include "units/containers.scm")
(include "units/dns.scm")


(define zeroconf-setup/debian
  (property-group "Set up zeroconf support."
    (package-service-enabled/apt "avahi-daemon")
    (pip:packages-installed "wsdd")
    (services-enabled "wsdd")))


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


(define fail2ban-enabled
  (package-service-enabled/pacman "fail2ban"))


(define prosody-enabled
  (package-service-enabled/pacman "prosody"))


(define radicale-enabled
  (package-service-enabled/pacman "radicale"))


(define znc-enabled
  (package-service-enabled/pacman "znc"))


(define internet-facing-properties
  (property-group "General internet protective properties"
                  fail2ban-enabled))


(define accountabilly-enabled
  (property-group "Accountabilly enabled."
   (local-image-copied "lazr/accountabilly:latest")
   (container-service-installed "~/src/lazr/accountabilly/accountabilly.container")
   (services-enabled "accountabilly")))


(define gitolite-enabled
  (property values))


(define grocy-enabled
  (property-group "Grocy enabled."
    (container-service-installed "units/grocy.container")

    (file-copied-to "units/20-grocy.conf"
                    "/etc/lighttpd/conf-available/20-grocy.conf")

    (file-linked/symbolic "/etc/lighttpd/conf-available/20-grocy.conf"
                          "/etc/lighttpd/conf-enabled")
                  
    (lighttpd-tested-config "/etc/lighttpd/conf-available/20-grocy.conf")
                  
    (services-restarted "lighttpd")))
