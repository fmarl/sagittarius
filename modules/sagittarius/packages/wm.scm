;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages wm)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages xdisorg)
  #:use-module (guix build-system asdf)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public nucleotide
  (package
    (name "nucleotide")
    (version "0.4.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/fmarl/nucleotide")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0l8z3f01zpa75mm2vs8xrnafik6ba7j9gr3v40586527h3mb44n6"))))
    (build-system asdf-build-system/sbcl)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'create-asdf-configuration 'build-program
            (lambda* (#:key outputs #:allow-other-keys)
              (build-program (string-append #$output "/bin/nucleotide")
                             outputs
                             #:dependencies '("nucleotide" "slynk"
                                              "slynk/mrepl")
                             #:dependency-prefixes (list #$output
                                                         #$(this-package-input
                                                            "sbcl-slynk"))
                             #:compress? #t
                             #:entry-program '((nucleotide::main))))))))
    (native-inputs (list libxkbcommon sbcl sbcl-fiveam))
    (inputs (list sbcl-slynk))
    (synopsis "Hackable Wayland window manager")
    (description
     "Nucleotide is a hackable Wayland window manager for the river compositor,
written in Common Lisp.")
    (home-page "https://codeberg.org/fmarl/nucleotide")
    (license license:gpl3+)))
