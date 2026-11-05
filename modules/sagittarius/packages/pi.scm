;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages pi)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages xorg)
  #:use-module (sagittarius build-system binary))

(define-public pi
  (package
    (name "pi")
    (version "1.5.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/earendil-works/pi/releases/"
                           "download/v" version "/pi-linux-x64.tar.gz"))
       (file-name (string-append name "-" version "-linux-x64.tar.gz"))
       (sha256
        (base32 "0fymd4hmr2nnd9rq95v6m0jx5f5qjy9z3n6qb0rppjs4wfh0p1yz"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; Stripping would remove the .bun section with the JavaScript.
      #:strip-binaries? #f
      ;; An RPATH can crash the binary, and the loader finds libc without one.
      #:validate-runpath? #f
      #:patchelf-plan
      #~'(("pi")
          ("native/linux/prebuilds/linux-x64/linux-platform-x11.node" ("libxcb")))
      #:install-plan
      #~'(("." "libexec/pi/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'wrap
            (lambda _
              (let ((pi (string-append #$output "/libexec/pi/pi")))
                ;; Pi looks for its assets next to the executable.
                (wrap-program pi
                  `("PI_PACKAGE_DIR" =
                    (,(dirname pi)))
                  `("PI_SKIP_VERSION_CHECK" =
                    ("1"))
                  `("PI_TELEMETRY" =
                    ("0"))
                  `("PI_SELF_UPDATE_COMMAND" =
                    (,#$(file-append coreutils-minimal "/bin/false"))))
                (mkdir-p (string-append #$output "/bin"))
                (symlink pi
                         (string-append #$output "/bin/pi"))))))))
    (inputs (list bash-minimal coreutils-minimal libxcb))
    (supported-systems '("x86_64-linux"))
    (home-page "https://pi.dev")
    (synopsis "Minimal AI coding agent for the terminal")
    (description
     "Pi is a minimal coding agent for the terminal.  It reads and edits
files and runs shell commands, and can be extended with TypeScript extensions,
skills and prompt templates.  It supports many model providers, including
local ones.")
    (license license:expat)))
