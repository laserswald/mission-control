
(define email-filter-installed
  (property-group "Email filter installed."
    (apt:packages-installed "notmuch" "msmtp")
    (directory-exists "/var/mail")))
