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

(define (web-server-configured/inline conf-str name)
  (property-group
   "Configuration file for web server installed"
   (file-has-contents (string-append "/etc/nginx/conf.d/" name)
                      conf-str)))

(define (web-server-site-installed local-file site)
  (property-group
   "Site configuration for web server installed"
   (file-copied-to local-file (string-append "/etc/nginx/sites-available/" site))))

(define (web-server-site-installed/inline conf-str site)
  (property-group
   "Site configuration for web server installed"
   (file-has-contents (string-append "/etc/nginx/sites-available/" site)
                      conf-str)))

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

;;;
;;; Reverse proxying to web applications.
;;;

;; Import templating from Gauche
(import (text template))
(import (scheme hash-table))
(import (scheme comparator))

(define-record-type <web-application>
  (web-application name domain-name internal-port)
  web-application?
  (name web-application-name)
  (domain-name web-application-domain-name)
  (internal-port web-application-internal-port))

;; install a web application to the nginx configuration on the remote host.
(define (web-application-site-installed app)
  (property-group
   (string-append "Web application " (web-application-name app) " enabled.")
   (web-server-site-installed/inline
    (expand-template-file "units/web-app-nginx.conf"
                          (make-template-environment
                           :bindings (alist->hash-table
                                      `((NAME . ,(web-application-name app))
                                        (DOMAIN-NAME . ,(web-application-domain-name app))
                                        (PORT . ,(web-application-internal-port app)))
                                      (make-default-comparator))))
    (web-application-name app))
   (web-server-site-enabled (web-application-name app))))
