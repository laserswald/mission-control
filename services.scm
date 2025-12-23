(include "units/users.scm")
(include "units/lighttpd.scm")
(include "units/containers.scm")
(include "units/dns.scm")
(include "units/web-server.scm")
(include "units/minecraft.scm")
(include "units/jukebox.scm")
(include "units/network.scm")

(define fail2ban-enabled/arch
  (package-service-enabled/pacman "fail2ban"))


(define fail2ban-enabled/debian
  (package-service-enabled/apt "fail2ban"))


(define prosody-enabled
  (package-service-enabled/pacman "prosody"))


(define radicale-enabled
  (package-service-enabled/pacman "radicale"))


(define znc-enabled
  (package-service-enabled/pacman "znc"))


(define internet-facing-properties/arch
  (property-group "General internet protective properties"
                  fail2ban-enabled/arch))


(define internet-facing-properties/debian
  (property-group "General internet protective properties"
                  fail2ban-enabled/debian))


(define accountabilly-enabled
  (property-group "Accountabilly enabled."
   (local-image-copied "lazr/accountabilly:latest")
   (container-service-installed "~/src/lazr/accountabilly/accountabilly.container")
   (services-enabled "accountabilly")))


(define gitolite-enabled
  (property-group "Gitolite enabled."
   (apt:packages-installed "gitolite3")
   (system-user-exists "git")))


(define grocy-enabled
  (property-group "Grocy enabled."
    (container-service-installed "units/grocy.container")

    (file-copied-to "units/20-grocy.conf"
                    "/etc/lighttpd/conf-available/20-grocy.conf")

    (file-linked/symbolic "/etc/lighttpd/conf-available/20-grocy.conf"
                          "/etc/lighttpd/conf-enabled")

    (lighttpd-tested-config "/etc/lighttpd/conf-available/20-grocy.conf")

    (services-restarted "lighttpd")))

(define bird-cam-receiver-enabled
  (let ((html-dir "/var/www/html/live"))
    (property-group
     "Bird camera receiver enabled."

     (apt:packages-installed "libnginx-mod-rtmp")

     (directory-exists html-dir)
     (file-permissions-set html-dir 755)

     (directory-exists "/tmp/live-stream-hls")

     (file-copied-to "units/bird-cam/stat.xsl" "/var/www/html/stat.xsl")

     (file-copied-to "units/bird-cam/bird-live.html"
                     "/var/www/html/live/index.html")

     (file-owned-by "/var/www/html/live/index.html"
                    "root" "www-data")

     (file-permissions-set "/var/www/html/live/index.html" 755)

     (web-server-configured "units/bird-cam/bird-cam.conf"
                            "99-bird-cam.conf")

     (web-server-site-installed "units/bird-cam/bird-cam-site.conf"
                                "bird-cam")

     (web-server-site-enabled "bird-cam")

     (web-server-enabled))))

(define (configure-bird-cam!)
  (display "Reloading mission control!\n")
  (load "mission-control.scm")
  (configure! (list bird-cam-receiver-enabled) andromeda))

(define (port-tunneled exposed-addr exposed-port internal-dest)

  (define (apply-firewall-rule! rule)
    (log/remote-host "checking firewall rule: " rule)
    (unless (do-remote-process `(iptables --check ,@rule))
      (log/remote-host "applying firewall rule: " rule)
      (do-remote-process! `(iptables --append ,@rule))))

  (property
   (lambda ()
     ;; Allow the initial packet
     (apply-firewall-rule!
      `(FORWARD "-i" ens3 -o wg0 -p tcp --syn --dport ,exposed-port -m conntrack --ctstate NEW -j ACCEPT))

     ;; Allow established connections in both directions
     (apply-firewall-rule!
      `(FORWARD "-i" ens3 -o wg0 -m conntrack --ctstate "ESTABLISHED,RELATED" -j ACCEPT))

     (apply-firewall-rule!
      `(FORWARD "-i" wg0 -o ens3 -m conntrack --ctstate "ESTABLISHED,RELATED" -j ACCEPT))

     ;; NAT to destination
     (apply-firewall-rule!
      `(PREROUTING --table nat
                   --protocol tcp
                   --in-interface ens3
                   --dport ,exposed-port
                   --jump DNAT
                   --to-destination ,internal-dest))

     ;; NAT to source
     (apply-firewall-rule!
      `(POSTROUTING
        --table nat
        --protocol tcp
        --out-interface wg0
        --destination ,internal-dest
        --dport ,exposed-port
        --jump SNAT
        --to-source ,exposed-addr))

     (log/remote-host "Installed port tunnel from " exposed-addr ":" exposed-port " -> " internal-dest))))


;; Create a property group that will set up sendmail to forward to the bot@lazr.space
;; email account.
(define (msmtp-email-sender secrets)
  (property-group
   (show #f "msmtp email forwarding enabled")
   (apt:packages-installed "msmtp" "msmtp-mta")
   (file-has-contents "/etc/msmtprc"
                      (list
                       "defaults"
                       "tls on"
                       "auth on"
                       "account bot"
                       "host mail.gandi.net"
                       "port 587"
                       "user bot@lazr.space"
                       "from bot@lazr.space"
                       "passwordeval cat /etc/secrets/msmtp-password"
                       "account default : bot"))

   ;; Install the secret file
   (directory-exists "/etc/secrets")
   (file-has-contents "/etc/secrets/msmtp-password"
                      (list (secret-ref secrets "sys/bot-email-password")))

   ;; Protect it by making it user and group readable only.
   ;; Debian installs an 'msmtp' user for us.
   (file-owned-by "/etc/secrets/msmtp-password" "root" "msmtp")
   (file-permissions-set "/etc/secrets/msmtp-password" "640")))

(define mail-sender-enabled
  (property-group
   (show #f "Email sending system enabled.")
   (apt:packages-installed "postfix" "mailutils" "opendkim" "opendkim-tools")
   (services-disabled "postfix")
   (file-has-contents
    "/etc/postfix/main.cf"
    (list
     "myhostname = french-fry.lazr.space"
     "myorigin = $mydomain"
     "relayhost = $mydomain"
     "inet_interfaces = loopback-only"
     "mydestination = "))
   (services-enabled "postfix")))

(define (system-monitor-enabled secrets)
  (property-group
   (show #f "System monitor installed and enabled")

   (msmtp-email-sender secrets)

   (file-copied-to
    "units/system-monitor/system-monitor.timer"
    "/etc/systemd/system/system-monitor.timer")

   (file-copied-to
    "units/system-monitor/system-monitor.service"
    "/etc/systemd/system/system-monitor.service")

   (file-copied-to
    "units/system-monitor/system-monitor.sh"
    "/usr/local/bin/system-monitor.sh")

   (file-permissions-set
    "/usr/local/bin/system-monitor.sh"
    "+x")

   daemon-reloaded

   (services-enabled "system-monitor.timer")))
