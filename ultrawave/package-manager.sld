(define-library (ultrawave package-manager)
  (export current-package-manager
          package-manager
          package-manager?
          packages-installed
          packages-removed
          packages-upgraded
          packages-cleaned

          package
          package-for-manager)

  (import (scheme base))

  (begin

    (define-record-type <package>
      (make-package canonical-name alternate-names)
      package?
      (canonical-name package-name)
      (alternate-names package-alternate-names))

    ;; A package is an alist of symbol/boolean to strings, where each symbol is
    ;; the name of a package manager.
    (define (package . names)
      (unless (alist? names)
        (error "make-package: expected an alist, but got " names))
      names)

    (define (package-for-manager package manager)
      (cond
       ((assoc (package-manager-name manager) package) => cdr)
       ((assoc #t package) => cdr)
       (else (error "package-for-manager: no package for " package manager))))

    (define-record-type <package-manager>
      (package-manager name install remove upgrade clean)
      package-manager?
      (name package-manager-name)
      (install package-manager-install)
      (remove package-manager-remove)
      (upgrade package-manager-upgrade)
      (clean package-manager-clean))))
