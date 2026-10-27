;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages wm)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (guix build-system asdf)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public nucleotide
  (let ((commit "3e966a42c641e844f6dfaf28cbc07fad83f2ec9c")
        (revision "4"))
    (package
      (name "nucleotide")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://codeberg.org/fmarl/nucleotide")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1gxg6yhr2g1r1iy5v396k4zxwc23nz4v9d54vf0wpni05prz2vx8"))))
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
      (native-inputs (list sbcl sbcl-fiveam))
      (inputs (list sbcl-slynk))
      (synopsis "Hackable Wayland window manager")
      (description
       "Nucleotide is a hackable Wayland window manager for the river compositor,
written in Common Lisp.")
      (home-page "https://codeberg.org/fmarl/nucleotide")
      (license license:gpl3+))))
