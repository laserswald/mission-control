
(define container-services-enabled/debian
  (property-group "Systemd container tools set up."
    (apt:packages-installed "systemd-container")
    (directory-exists "/etc/containers/systemd")))

(define (container-service-installed service-file)
  (property-group (show #f "Container service installed:" service-file)
    container-services-enabled/debian
    (file-copied-to service-file "/etc/containers/systemd/")))
