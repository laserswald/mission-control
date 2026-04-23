(import
 (scheme base)
 (ultrawave base)
 (ultrawave wireguard)
 (ultrawave filesystem)
 (ultrawave secret)
 (ultrawave container))

;;; Generate wireguard peers.

(define (names->peers prefix names)
  (let ((ip-last 1))
    (map (lambda (name)
           (let ((peer (wireguard-peer name (string-append prefix (number->string ip-last))))) 
             (set! ip-last (+ 1 ip-last))
             peer))
         names)))

(define wireguard-service-names
  (list "sol"
        "sirius"
        "andromeda"
        "baked"
        "vespa"))
        
(define wireguard-user-names
  (list "ben-phone"
        "ben-laptop"
        "julia-phone"
        "julia-laptop"
        "gina"
        "robin"
        "miriam"
        "chloe"
        "nathan"
        "megan"
        "victoria"
        "colton"))

(define storage-users
  (list "ben" "jules" "miriam" "megan" "gina" "robin"))

(define wireguard-peers
  (append (names->peers "10.1.0." wireguard-service-names)
          (names->peers "10.1.1." wireguard-user-names)))

(define lazr-internal-vpn
  (wireguard-network (car wireguard-peers) ;; Should be Sol
                     (cdr wireguard-peers)))

         
