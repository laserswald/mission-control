;;;; syncthing - manage secure synchronization of data
(define-library (syncthing)
  (export folder folder? folder-label folder-identifier

          device device? device-identifier
	  host->device

          server-enabled)

  (import (scheme base)
          (ultrawave command)
          (ultrawave host))

  (begin

    (define folder-types '(send-receive send-only receive-only))

    ;;; Folders represent a synchronized directory across devices.
    (define-record-type <folder>
      (folder label identifier type)
      folder?
      (label folder-label)
      (identifier folder-identifier)
      (type folder-type))

    ;;; Device represents a computer or phone that can synchronize with other devices.
    (define-record-type <device>
      (device identifier)
      device?
      (identifier device-identifier))

    (define (host->device host)
      ;; Once it is ready, we can return a device instance that contains the identifier.
      (device (process->string/remote '(syncthing device-id))))

    (define-record-type <configuration>
      (configuration user)
      configuration?
      (user configuration-user))

    (define (server-enabled host configuration) ; -> device?
      ;; On debian/ubuntu, we need the Syncthing apt repo

      ;; Install syncthing
      (package-installed "syncthing")

      ;; Set up the user
      (system-user-exists (configuration-user))

      ;; And enable the system service
      (service-enabled (string-append "syncthing@" (configuration-user))))

    ))

