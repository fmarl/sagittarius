(define-module (sagittarius packages security)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages python)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages tls))

(define-public sqlmap
  (package
    (name "sqlmap")
    (version "1.9")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/sqlmapproject/sqlmap")
                    (commit "fee62ae14c15e555662b1d1099304add3eff3b1c")))
              (sha256
               (base32 "1kci95aavjqcprzg5dw2sjcd7cd93ljn4sxvnqnf5hrh6rh8h2ig"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let* ((src (assoc-ref %build-inputs "source"))
                (out (assoc-ref %outputs "out"))
                (bin (string-append out "/bin"))
                (bash (string-append (assoc-ref %build-inputs "bash") "/bin/bash"))
                (py (string-append (assoc-ref %build-inputs "python") "/bin/python3")))
           (mkdir-p bin)
           (copy-recursively src out)
           (with-directory-excursion bin
             (call-with-output-file "sqlmap"
               (lambda (p)
                 (format p "#!~a
exec ~a ~a/sqlmap.py \"$@\"" bash py out)))
             (chmod "sqlmap" #o555)
             #t)))))
    (inputs `(("python" ,python)
              ("bash" ,bash-minimal)
              ("openssl" ,openssl)))
    (synopsis "Automatic SQL injection and database takeover tool")
    (description "sqlmap is an open source penetration testing tool that automates the process of detecting and exploiting SQL injection flaws and taking over of database servers. It comes with a powerful detection engine, many niche features for the ultimate penetration tester, and a broad range of switches including database fingerprinting, over data fetching from the database, accessing the underlying file system, and executing commands on the operating system via out-of-band connections.")
    (home-page "https://sqlmap.org")
    (license license:gpl2)))
