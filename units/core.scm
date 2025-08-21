(import (scheme base)
        (scheme load))

(load "units/users.scm")

(define (package-service-enabled/pacman package)
  (property-group 
   (show #f package " installed and enabled.")
   (pacman:packages-installed package)
   (services-enabled package)))

(define (package-service-enabled/apt package)
  (property-group 
   (show #f package " installed and enabled.")
   (apt:packages-installed package)
   (services-enabled package)))

(define core-setup/arch
  (property-group "Core set up for Arch system."
    (users-set-up pass-secret-storage)
    pacman:updated
    (pacman:packages-installed "tmux" "zsh")))

(define core-setup/debian
  (property-group "Core set up for Debian system."
    (users-set-up pass-secret-storage)
    apt:updated
    apt:upgraded
    apt:cleaned
    (apt:packages-installed "tmux" "zsh" "python3-pip")))
