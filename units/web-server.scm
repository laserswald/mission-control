;;;; web-server.scm - Configure nginx on the remote node
;;;;
;;;;

(import (ultrawave filesystem))

(define (web-server-enabled)
  (property-group
   "Web server is enabled."
   (apt:packages-installed "nginx")
   (file-copied-to "units/nginx.conf" (string-append "/etc/nginx/nginx.conf"))
   (services-enabled "nginx")))

(define (web-server-configured cfg-file name)
  (property-group
   "Configuration file for web server installed"
   (file-copied-to cfg-file (string-append "/etc/nginx/conf.d/" name))))

(define (web-server-site-installed local-file site)
  (property-group
   "Site configuration for web server installed"
   (file-copied-to local-file (string-append "/etc/nginx/sites-available/" site))))

(define (web-server-site-enabled site)
  (property-group
   "Website enabled"
   (file-linked/symbolic (string-append "/etc/nginx/sites-available/" site)
			 (string-append "/etc/nginx/sites-enabled/" site))
   (services-restarted "nginx")))

(define (web-server-site-disabled site-name)
  (property-group
   "Website disabled"
   (shell-command-property `(rm -f ,(string-append "/etc/nginx/sites-enabled/" site-name)))
   (services-restarted "nginx")))
