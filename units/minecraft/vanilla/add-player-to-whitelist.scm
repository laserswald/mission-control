(import (scheme base)
        (gauche)
        (rfc http)
        (rfc json))

(define (lookup-player-id player-name)
  (let-values (((code headers body)
                (http-get "api.mojang.com" 
                         (string-append "/users/profiles/minecraft/"
                                        player-name))))
    (unless (equal? code "200")
      (error "Failed:" code headers body))
    (reformat-uuid (cdr (assoc "id" (parse-json-string body))))))

(define (reformat-uuid uuid)
  (string-append (substring uuid 0 8) "-"
		 (substring uuid 8 12) "-"
		 (substring uuid 12 16) "-"
		 (substring uuid 16 20) "-"
		 (substring uuid 20 32)))

(define (player-entry player-name)
  `(("name" . ,player-name)
    ("uuid" . ,(lookup-player-id player-name))))

(define (adjoin-player whitelist player)
  (vector-append whitelist (vector (player-entry "Laserswald")))
