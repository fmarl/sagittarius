;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-build)
  #:use-module (guix build-system pyproject)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public python-virtme-ng
  (package
    (name "python-virtme-ng")
    (version "1.41")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/arighi/virtme-ng")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0dpim9675p15ja993gj1xh7dq79dgh1w9lp0ym2yryfd7wsbc7zx"))))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f                       ;no test suite
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'remove-mcp-entry-point
            (lambda _
              ;; Needs the optional "mcp" extra, but python-mcp in Guix lacks
              ;; some of its dependencies.
              (substitute* "setup.py"
                ((".*\"vng-mcp = .*") "")))))))
    (propagated-inputs (list python-argcomplete python-requests))
    (native-inputs (list python-argparse-manpage python-setuptools))
    (home-page "https://github.com/arighi/virtme-ng")
    (synopsis
     "Build and run a kernel inside a virtualized snapshot of your live system")
    (description
     "virtme-ng builds a Linux kernel from source with a minimal configuration
and boots it in QEMU on a copy-on-write snapshot of the host file system.
Changes made inside the virtual machine do not affect the host.")
    (license license:gpl2)))
