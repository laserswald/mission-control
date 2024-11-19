
(define ultrawave-dnsmasq-file
  "/etc/dnsmasq.d/99-services.conf")

;;; TODO: this does not work. We need to do some sort of concatenation
;;; here
(define dns-record-properties '())

(define (add-dns-record-property! property)
  (set! dns-record-properties
        (cons property dns-record-properties)))

;;; Register a canonical name entry to the dnsmasq configuration.
(define (dns-cname-registered alias canonical)
  (property-group (string-append "Registered CNAME " alias " => " canonical)
   (file-has-line ultrawave-dnsmasq-file
                  (string-append "cname=" alias "," canonical))
   (services-restarted "pihole-FTL")))


;;; Register a SRV name entry to the dnsmasq configuration.
(define (dns-srv-registered name transport domain server port)
  (property-group
   (string-append "Registered SRV record for "
                  name " via " transport " in " domain " to "
                  server ":" port)
   (file-has-line ultrawave-dnsmasq-file 
                  (string-append "srv-host="
                                 "_" name "." "_" transport "." domain ","
                                 server ","
                                 (number->string port)))
   (services-restarted "pihole-FTL")))
