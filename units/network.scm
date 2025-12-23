
(define zeroconf-setup/debian
  (property-group "Set up zeroconf support."
    (package-service-enabled/apt "avahi-daemon")
    (pip:packages-installed "wsdd")
    (services-enabled "wsdd")))

