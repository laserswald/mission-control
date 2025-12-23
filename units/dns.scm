
(define-record-type <dns-service>
  (dns-service add-cname-proc
               add-srv-proc)
  dns-service?
  (add-cname-proc dns-service-add-cname-proc)
  (add-srv-proc dns-service-add-srv-proc))

(define (dns-cname-registered dns alias canonical)
  ((dns-service-add-cname-proc dns) alias canonical))

(define (dns-srv-registered dns name transport domain server port)
  ((dns-service-add-srv-proc dns) name transport domain server port))

(define (dnsmasq-dns-service service-name)

  (define ultrawave-dnsmasq-file
    "/etc/dnsmasq.d/99-services.conf")

  ;;; Register a canonical name entry to the dnsmasq configuration.
  (define (cname-registered alias canonical)
    (property-group (string-append "Registered CNAME " alias " => " canonical)
     (file-has-line ultrawave-dnsmasq-file
                    (string-append "cname=" alias "," canonical))
     (services-restarted service-name)))


  ;;; Register a SRV name entry to the dnsmasq configuration.
  (define (srv-registered name transport domain server port)
    (property-group
     (string-append "Registered SRV record for "
                    name " via " transport " in " domain " to "
                    server ":" port)
     (file-has-line ultrawave-dnsmasq-file
                    (string-append "srv-host="
                                   "_" name "." "_" transport "." domain ","
                                  server ","
                                  (number->string port)))
     (services-restarted service-name)))

  (dns-service cname-registered
               srv-registered))

